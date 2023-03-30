public class OpportunityPDFExtension {
    private final Opportunity opportunity;
    
    public OpportunityPDFExtension(ApexPages.StandardController stdController) {
        Opportunity opportunity = (Opportunity)stdController.getRecord();
        this.opportunity = [SELECT Id, ContactId, AccountId  FROM Opportunity WHERE Id = :opportunity.Id LIMIT 1];
    }
    public Contact getContact(){
        Contact result = [SELECT Id, Name, Phone, Email FROM Contact WHERE Id = :this.opportunity.ContactId LIMIT 1];
        return result;
    }
    public Account getAccount(){
        Account result = [SELECT Id, Name FROM Account WHERE Id = :this.opportunity.AccountId LIMIT 1];
        return result;
    }
}