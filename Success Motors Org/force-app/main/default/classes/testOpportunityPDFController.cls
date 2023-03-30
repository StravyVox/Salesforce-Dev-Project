@isTest
public class testOpportunityPDFController {
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
    static void testSuccessfulCreatedDocument() {
        Opportunity op = [SELECT Id, Name From Opportunity Where StageName='Prospecting' LIMIT 1];
        Integer expected = 2;
        Test.startTest();
           Integer result = OpportunityPDFController.CreateDocument(op.Id);
        Test.stopTest();
        Assert.areEqual(expected, result);
    }
    @IsTest
    static void testErrorOnCreatingDocument() {
         Integer expected = -1;
        Test.startTest();
           Integer result = OpportunityPDFController.CreateDocument('GGh33315');
        Test.stopTest();
        Assert.areEqual(expected, result);
    }
    @IsTest
    static void testSuccessfulUpdatedDocument() {
        Opportunity op = [SELECT Id, Name From Opportunity Where StageName='Prospecting' LIMIT 1];
        Integer expected = 1;
        OpportunityPDFController.CreateDocument(op.Id);
        Test.startTest();
            Integer result = OpportunityPDFController.CreateDocument(op.Id);
        Test.stopTest();
        Assert.areEqual(expected, result);
    }
}