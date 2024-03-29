public with sharing class OpportunityEmailController {
    @AuraEnabled
    public static String returnPrimaryRoleAccount(String OpportunityID){
        try{
            OpportunityContactRole contact = [SELECT ContactId From OpportunityContactRole WHERE OpportunityId = :OpportunityID lIMIT 1];
            Contact contactFromSOQL =  [SELECT Id, Name, Email FROM Contact Where Id = :contact.ContactId LIMIT 1];
            String jsonContact = JSON.serialize(contactFromSOQL);
            return jsonContact;
        }
        catch(System.QueryException ex){
            return null; 
        }
    }
    @AuraEnabled
    public static String returnTemplateSubject(String OpportunityID, String TemplateName){
        try{
           EmailTemplate template = [SELECT Subject FROM EmailTemplate WHERE Name = :TemplateName LIMIT 1];
           Opportunity op = [SELECT Invoice_Number__c from Opportunity Where Id =:OpportunityID LIMIT 1];
           return template.Subject + ' ' + op.Invoice_Number__c;
        }
        catch(System.QueryException ex){
            return null; 
        }
    }
    @AuraEnabled
    public static String returnTemplateBody(String OpportunityID,String TemplateName){
        try{
            EmailTemplate template = [SELECT htmlvalue FROM EmailTemplate WHERE Name = :TemplateName LIMIT 1];
            Opportunity op = [SELECT Invoice_Number__c from Opportunity Where Id =:OpportunityID LIMIT 1];
            Pattern regExpPattern = Pattern.compile('mailto:');
            Matcher regExpMatcher = regExpPattern.matcher(template.htmlvalue);
            if(regExpMatcher.find()){
                
                List<EmailServicesFunction> idOfService = [SELECT Id, attachmentOption FROM EmailServicesFunction WHERE FunctionName = 'OpportunityAnswerService' ];
                EmailServicesAddress adress=  [SELECT Id, LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId = :idOfService[0].Id LIMIT 1];
                Integer position = regExpMatcher.end();
                template.HtmlValue = template.HtmlValue.substring(0, position) + adress.LocalPart + '@'+adress.EmailDomainName
                +'?body=approved&subject='+op.Invoice_Number__c + template.HtmlValue.substring(position);
                return template.htmlvalue;
            }
            return template.htmlvalue;
        }
        catch(System.QueryException ex){
            return null; 
        }
    }
    @AuraEnabled
    public static Integer sendMail(String emailDetail) {
        EmailWrapper emailDetails = (EmailWrapper) JSON.deserialize(emailDetail, EmailWrapper.class);
        Messaging.reserveSingleEmailCapacity(1);
        try {
            messaging.SingleEmailMessage mail = new messaging.SingleEmailMessage();
            mail.setToAddresses(emailDetails.toAddress);
            mail.setSubject(emailDetails.subject);
            mail.setHtmlBody(emailDetails.body);
            mail.setEntityAttachments(findFileForOpportunity(emailDetails.opportunityId));
            Messaging.sendEmail(new List<messaging.SingleEmailMessage>{ mail });
            return 1;
        } catch (exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    private static List<String> findFileForOpportunity(String OpportunityID){
        try{
            List<String> result = new List<String>();
            Opportunity op = [SELECT Invoice_Number__c FROM Opportunity WHERE ID = :OpportunityID LIMIT 1];
            ContentDocument doc = [SELECT ID, LatestPublishedVersionId FROM ContentDocument Where Title = :op.Invoice_Number__c LIMIT 1];
            result.add(doc.LatestPublishedVersionId);
            return result;
        }
        catch(System.QueryException ex){
            return null;
        }
    }
    @TestVisible Class EmailWrapper {
        public String opportunityId;
        public List<String> toAddress;
        public String subject;
        public String body;
    }
}