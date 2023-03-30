@isTest
public class testOpportunityPDFExtension {
    @TestSetup
    static void makeData(){
        Contact testCon = new Contact(
            FirstName='TestContact',
            LastName='Test'
        );
        Account testAcc = new Account(
            Name='TestAccount'
        );
        insert testAcc;
        insert testCon;
        Opportunity testOpportunity = new Opportunity(
            Name='TestOp',
            StageName='Prospecting',
            CloseDate=Date.today().addDays(3),
            AccountId=testAcc.Id,
            ContactId=testCon.Id
            );
        insert testOpportunity;
    }
    @IsTest
    static void testContact() {
        Opportunity op = [SELECT Id, Name From Opportunity Where Name = 'TestOp' LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(op);
        OpportunityPDFExtension extension = new OpportunityPDFExtension(sc);
        Test.startTest();
            Contact contact = extension.getContact();
        Test.stopTest();
        Assert.areEqual('TestContact Test',contact.Name);
    }
    @IsTest
    static void testAccount() {
        Opportunity op = [SELECT Id, Name From Opportunity Where Name = 'TestOp' LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(op);
        OpportunityPDFExtension extension = new OpportunityPDFExtension(sc);
        Test.startTest();
            Account contact = extension.getAccount();
        Test.stopTest();
        Assert.areEqual('TestAccount',contact.Name);
    }
}