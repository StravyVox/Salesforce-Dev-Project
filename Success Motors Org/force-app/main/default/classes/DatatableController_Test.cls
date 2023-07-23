@isTest
public class DatatableController_Test {
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
            Case testCase = new Case(
                Status = 'New',
                Origin = 'Phone'
            );
            insert testCase;
        }
        @IsTest
        static void testReturnOpportunities(){
            Test.startTest();
                List<Opportunity> opportunities = DatatableController.ReturnOpportunities();
            Test.stopTest();
            System.assert(opportunities[0].Name == 'TestOp');
        }
        @IsTest
        static void testReturnCases(){
            
            Test.startTest();
                List<Case> cases = DatatableController.ReturnCases();
            Test.stopTest();
            System.assert(cases[0].Status == 'New');
            
        }
}