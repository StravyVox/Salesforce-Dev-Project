@isTest
public class testAccountDetailController {
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
    static void testGetAccountsListJSON(){
        Account checkAcc = new Account(
            Name='TestAccount'
        );
        
        Test.startTest();
        AccountDetailController.AccountInfo[] info = AccountDetailController.getAccountInfoList();
        Test.stopTest();
        Assert.areEqual(checkAcc.Name, info[0].name);
        
    }
    @IsTest
    static void testSearchByNameOfAccount(){
        String searchString = 'Test';
        
        Test.startTest();
        AccountDetailController.AccountInfo[] info = AccountDetailController.SearchByNameOfAccount(searchString);
        Test.stopTest();
        Assert.areEqual('TestAccount', info[0].name);   
    }
    @IsTest
    static void testFailSearchByNameOfAccount(){
        String searchString = 'TestAlhlhlhlhlh';
        
        Test.startTest();
        AccountDetailController.AccountInfo[] result = AccountDetailController.SearchByNameOfAccount(searchString);
        Test.stopTest();
        Assert.areEqual(null, result);   
    }
    @IsTest
    static void testSearchBySumOfOpportunities(){
        String searchString = '1';
        
        Test.startTest();
        AccountDetailController.AccountInfo[] info = AccountDetailController.SearchBySumOfOpportunities(searchString);
        Test.stopTest();
        Assert.areEqual('TestAccount', info[0].name);   
    }
    @IsTest
    static void testFailSearchBySumOfOpportunities(){
        String searchString = '50';
        
        Test.startTest();
        AccountDetailController.AccountInfo[] result = AccountDetailController.SearchBySumOfOpportunities(searchString);
        Test.stopTest();
        Assert.areEqual(null, result);   
    }
    
    @IsTest
    static void testGetAccount(){
        Account checkAcc = [SELECT ID, Name FROM ACCOUNT WHERE NAME = 'TestAccount' LIMIT 1];
        
        Test.startTest();
        AccountDetailController.AccountInfo info = AccountDetailController.getAccount(checkAcc.Id);
        Test.stopTest();
        Assert.areEqual(checkAcc.Name, info.name);
        
    }
   
}