public with sharing class OpportunityPDFController {
   
    @AuraEnabled
    public static String getAttachedDocumentID(String OpportunityID){
        try{
            ContentDocumentLink returnedDocumentLink = [SELECT ContentDocumentId FROM ContentDocumentLink Where LinkedEntityId = :OpportunityID LIMIT 1];
            return returnedDocumentLink.ContentDocumentId;
        }
        catch(System.QueryException ex){
            return null;
        }
    }
    @AuraEnabled
    public static Integer createDocument(String OpportunityID){
        ApexPage opportunityPage = [SELECT Name,NamespacePrefix FROM ApexPage WHERE NAME = 'OpportunityPDF' AND NamespacePrefix = 'SMotors'];
        System.debug('/apex/'+opportunityPage.NamespacePrefix+'__'+opportunityPage.Name);
        PageReference opportunityPDFFile = new Pagereference('/apex/'+opportunityPage.NamespacePrefix+'__'+opportunityPage.Name);
        
        opportunityPDFFile.getParameters().put('id', OpportunityID);
        try{
            Opportunity op = [SELECT Invoice_Number__c FROM Opportunity WHERE ID = :OpportunityID LIMIT 1];
            ContentVersion cont = new ContentVersion();
            cont.Title = op.Invoice_Number__c;
            cont.PathOnClient = op.Invoice_Number__c+'.pdf';
            if(Test.isRunningTest()) { 
                cont.VersionData = blob.valueOf('Unit.Test');
            } 
            else{
                cont.VersionData = opportunityPDFFile.getContentAsPDF();
            }
            cont.Origin = 'H';
            return upsertContentVersion(cont, op);
        }
        catch(System.QueryException ex){
            return -1;
        }
       
    }
    private static Integer upsertContentVersion(ContentVersion newContentVersion, Opportunity opportunity){
        try{
            ContentDocument document = [SELECT ID FROM ContentDocument WHERE Title = :newContentVersion.Title LIMIT 1];
            newContentVersion.ContentDocumentId = document.Id;            
            try{
                upsert newContentVersion;
                return 1;
            }
            catch(DmlException e){
                return -1;
            }
        }
        catch(System.QueryException ex){
            insert newContentVersion;
            generateLink(newContentVersion.Id, opportunity.Id);
            return 2;
            
        }
    }
    private static void generateLink(String contentID, String OpportunityID){
        ContentVersion contentVer = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentID LIMIT 1];
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = OpportunityID;
        contentlink.contentdocumentid = contentVer.contentdocumentid;
        contentlink.ShareType = 'V';
        upsert contentlink; 
    }
}