@isTest
public class PaymentTrigger_Test {
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
            Amount = 500,
            CloseDate=Date.today().addDays(3),
            AccountId=testAcc.Id,
            ContactId=testCon.Id
            );
        insert testOpportunity;
    }
    @IsTest
    static void testPartPaid(){
        Payment__c testPayment = new Payment__c(
            OpportunityName__c = 'TestOp',
            Amount__c = 250,
            FirstName__c = 'TestFName',
            LastName__c = 'TestLName'
        );
        Test.startTest();
            insert testPayment;
        Test.stopTest();
        Opportunity testingOpportunity = [SELECT StageName from Opportunity WHERE Name = 'TestOp' limit 1];
        System.assert(testingOpportunity.StageName == 'Partially Paid');
    }
    
    @IsTest
    static void testFullyPaid(){
        Payment__c testPayment = new Payment__c(
            OpportunityName__c = 'TestOp',
            Amount__c = 550,
            FirstName__c = 'TestFName',
            LastName__c = 'TestLName'
        );
        Test.startTest();
            insert testPayment;
        Test.stopTest();
        Opportunity testingOpportunity = [SELECT StageName from Opportunity WHERE Name = 'TestOp' limit 1];
        List<Task> createdTasks = [SELECT ID FROM Task WHERE Subject = 'Delivery of goods'];
        System.assert(testingOpportunity.StageName == 'Fully Paid');
        System.assert(createdTasks.size()>0);
    }
}