public with sharing class DatatableController {
    @AuraEnabled (cacheable=true)
    public static List<Opportunity> ReturnOpportunities (){
        List<Opportunity> opportunities = [SELECT Id,Name, StageName, CreatedDate, SMotors__Invoice_Number__c FROM OPPORTUNITY];
        return opportunities;
    }
    @AuraEnabled (cacheable=true)
    public static List<Case> ReturnCases (){
        List<Case> cases = [SELECT Id,CaseNumber, Product__c, Status, CreatedDate, Type FROM CASE];
        return cases;
    }
}