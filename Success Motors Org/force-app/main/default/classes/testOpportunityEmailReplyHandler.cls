@isTest
public class testOpportunityEmailReplyHandler {
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
    static void testHandleInboundEmailApproved(){
        Opportunity op = [SELECT ID, NAME, STAGENAME, Invoice_Number__c FROM Opportunity WHERE Name='TestOp' LIMIT 1];
        OpportunityEmailReplyHandler testHandler = new OpportunityEmailReplyHandler();

        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env    = new Messaging.InboundEnvelope();
        // Test with the subject that matches the unsubscribe statement.
        email.subject = op.Invoice_Number__c;
        email.plainTextBody = 'approved';
        env.fromAddress = 'user@acme.com';
        Test.startTest();
            Messaging.InboundEmailResult result = testHandler.handleInboundEmail(email, env);
        Test.stopTest();
        Assert.areEqual(true, result.success);
       
    }
    static void testHandleInboundEmailInBody(){
        Opportunity op = [SELECT ID, NAME, STAGENAME, Invoice_Number__c FROM Opportunity WHERE Name='TestOp' LIMIT 1];
        OpportunityEmailReplyHandler testHandler = new OpportunityEmailReplyHandler();

        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        // Test with the subject that matches the unsubscribe statement.
        email.subject = 'Wrong Subject';
        email.plainTextBody = op.Invoice_Number__c +' rejected';
        env.fromAddress = 'user@acme.com';
        Test.startTest();
            Messaging.InboundEmailResult result = testHandler.handleInboundEmail(email, env);
        Test.stopTest();
        Assert.areEqual(true, result.success);
       
    }
    static void testHandleInboundEmailNoMessage(){
        Opportunity op = [SELECT ID, NAME, STAGENAME, Invoice_Number__c FROM Opportunity WHERE Name='TestOp' LIMIT 1];
        OpportunityEmailReplyHandler testHandler = new OpportunityEmailReplyHandler();

        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env    = new Messaging.InboundEnvelope();
        // Test with the subject that matches the unsubscribe statement.
        email.subject = op.Invoice_Number__c;
        email.plainTextBody = 'rej';
        env.fromAddress = 'user@acme.com';
        Test.startTest();
            Messaging.InboundEmailResult result = testHandler.handleInboundEmail(email, env);
        Test.stopTest();
        Assert.areEqual(false, result.success);
        Assert.areEqual('Sorry, but we couldn\'t find any approved or rejected message in your email', result.message);
    }
    
    @IsTest
    static void testSetResultsOfOpportunityApproved(){
        Opportunity op = [SELECT ID, NAME, STAGENAME, Invoice_Number__c FROM Opportunity WHERE Name='TestOp' LIMIT 1];
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        email.plainTextBody = 'I may say it is approved';
        OpportunityEmailReplyHandler testHandler = new OpportunityEmailReplyHandler();
        Test.startTest();
            string result = testHandler.SetResultOfOpportunity(op.Invoice_Number__c, email);
            email.plainTextBody = '';
            string result2 = testHandler.SetResultOfOpportunity(op.Invoice_Number__c, email);
        Test.stopTest();
        Assert.areEqual('', result);
        op = [SELECT ID, NAME, STAGENAME, Invoice_Number__c FROM Opportunity WHERE Name='TestOp' LIMIT 1];
        Assert.areEqual('Qualification', op.StageName);
        Assert.areEqual('Sorry, but we couldn\'t find any approved or rejected message in your email', result2);
    }
    @IsTest
    static void testSetResultsOfOpportunityRejected(){
        Opportunity op = [SELECT ID, NAME, STAGENAME, Invoice_Number__c FROM Opportunity WHERE Name='TestOp' LIMIT 1];
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        email.plainTextBody = 'I may say it is rejected';
        OpportunityEmailReplyHandler testHandler = new OpportunityEmailReplyHandler();
        Test.startTest();
            string result = testHandler.SetResultOfOpportunity(op.Invoice_Number__c, email);
        Test.stopTest();
        Assert.areEqual('', result);
        op = [SELECT ID, NAME, STAGENAME, Invoice_Number__c FROM Opportunity WHERE Name='TestOp' LIMIT 1];
        Assert.areEqual('Closed Lost', op.StageName);
    }
    @IsTest
    static void testFindStringByPattern(){
        string pattern='test';
        String findString = 'some test string';
        OpportunityEmailReplyHandler testHandler = new OpportunityEmailReplyHandler();
        string result = testHandler.FindStringByPattern(pattern,findString);
        findString = 'tes string';
        string result2 = testHandler.FindStringByPattern(pattern,findString);
        
        Assert.areEqual('test', result);
        Assert.areEqual('', result2);
    }
    public testOpportunityEmailReplyHandler() {

    }
}