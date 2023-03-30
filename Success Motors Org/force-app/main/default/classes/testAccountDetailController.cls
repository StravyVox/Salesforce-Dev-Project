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
        AccountDetailController.AccountInfo[] info = (AccountDetailController.AccountInfo[])JSON.deserialize(AccountDetailController.getAccountsListJSON(), AccountDetailController.AccountInfo[].class);
        Test.stopTest();
        Assert.areEqual(checkAcc.Name, info[0].name);
        
    }
    @IsTest
    static void testSearchByNameOfAccount(){
        String searchString = 'Test';
        
        Test.startTest();
        AccountDetailController.AccountInfo[] info = (AccountDetailController.AccountInfo[])JSON.deserialize(AccountDetailController.SearchByNameOfAccount(searchString), AccountDetailController.AccountInfo[].class);
        Test.stopTest();
        Assert.areEqual('TestAccount', info[0].name);   
    }
    @IsTest
    static void testFailSearchByNameOfAccount(){
        String searchString = 'TestAlhlhlhlhlh';
        
        Test.startTest();
        String result = AccountDetailController.SearchByNameOfAccount(searchString);
       Test.stopTest();
        Assert.areEqual(null, result);   
    }
    @IsTest
    static void testSearchBySumOfOpportunities(){
        String searchString = '1';
        
        Test.startTest();
        AccountDetailController.AccountInfo[] info = (AccountDetailController.AccountInfo[])JSON.deserialize(AccountDetailController.SearchBySumOfOpportunities(searchString), AccountDetailController.AccountInfo[].class);
        Test.stopTest();
        Assert.areEqual('TestAccount', info[0].name);   
    }
    @IsTest
    static void testFailSearchBySumOfOpportunities(){
        String searchString = '50';
        
        Test.startTest();
        String result = AccountDetailController.SearchBySumOfOpportunities(searchString);
        Test.stopTest();
        Assert.areEqual(null, result);   
    }
    
    @IsTest
    static void testGetAccount(){
        Account checkAcc = [SELECT ID, Name FROM ACCOUNT WHERE NAME = 'TestAccount' LIMIT 1];
        
        Test.startTest();
        AccountDetailController.AccountInfo info = (AccountDetailController.AccountInfo)JSON.deserialize(AccountDetailController.getAccount(checkAcc.Id), AccountDetailController.AccountInfo.class);
        Test.stopTest();
        Assert.areEqual(checkAcc.Name, info.name);
        
    }
    @IsTest
    static void testGetOpportunities(){
        Account checkAcc = [SELECT ID FROM ACCOUNT WHERE NAME = 'TestAccount' LIMIT 1];
        
        Test.startTest();
        List<Opportunity> opportunities = AccountDetailController.getOpportunities(checkAcc.Id);
        Test.stopTest();
        Assert.areEqual(1, opportunities.size());
        Assert.areEqual('TestOp', opportunities[0].Name);
        
        
    }

}