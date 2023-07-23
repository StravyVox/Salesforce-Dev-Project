@isTest
public class PaymentTriggerController_Test {
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
        Payment__c testPayment = new Payment__c(
            OpportunityName__c = 'TestOp',
            Amount__c = 250,
            FirstName__c = 'TestFName',
            LastName__c = 'TestLName'
        );
        insert testPayment;
    }
    @IsTest
    static void testGetPaymentList(){
        Payment__c testPayment = [SELECT Amount__c FROM PAYMENT__c WHERE OpportunityName__c = 'TestOp' LIMIT 1];
        Opportunity testOpportunity = [SELECT Name FROM Opportunity LIMIT 1];
        Test.startTest();
            Map<String, Decimal> result = PaymentTriggerController.getPaymentList();
        Test.stopTest();
        System.assert(result.get(testOpportunity.Name) == testPayment.Amount__c);
        
    }
    @IsTest
    static void testUpdateOpprtunities(){
        Test.startTest();
            Map<String, Decimal> paymentList = PaymentTriggerController.getPaymentList();
            List<Opportunity> result = PaymentTriggerController.updateOpportunities(paymentList);
        Test.stopTest();
        System.assert(result.size()==1);
        System.assert(result[0].StageName == 'Partially Paid');
        
    }
    
    @IsTest
    static void testSetTasksForOpportunities(){
        Payment__c testPayment = new Payment__c(
            OpportunityName__c = 'TestOp',
            Amount__c = 550,
            FirstName__c = 'TestFName',
            LastName__c = 'TestLName'
        );
        insert testPayment;
        Test.startTest();
            Map<String, Decimal> paymentList = PaymentTriggerController.getPaymentList();
            List<Opportunity> result = PaymentTriggerController.updateOpportunities(paymentList);
            List<Task> tasks = PaymentTriggerController.setTasksForOpportunities(result);
        Test.stopTest();
        System.assert(tasks.size()==1);
        System.assert(result[0].StageName == 'Fully Paid');
        
    }
}