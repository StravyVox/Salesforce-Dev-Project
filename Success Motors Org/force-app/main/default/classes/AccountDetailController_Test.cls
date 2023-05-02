@isTest
public class AccountDetailController_Test {
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
            StageName='Closed Won',
            Amount = 500,
            CloseDate=Date.today().addDays(3),
            AccountId=testAcc.Id,
            ContactId=testCon.Id
            );
        insert testOpportunity;
        Id pricebookId = Test.getStandardPricebookId();
        Product2 prod = new Product2(
            Name = 'Product X',
            ProductCode = 'Pro-X',
            isActive = true
        );
        insert prod;
        PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert pbEntry;
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = testOpportunity.Id,
            Quantity = 5,
            PricebookEntryId = pbEntry.Id,
            TotalPrice = 5 * pbEntry.UnitPrice
        );
        insert oli;
    }
    @IsTest
    static void testGetAccountsListJSON(){
        
        String Name='TestAccount';
        
        
        Test.startTest();
        AccountDetailController.AccountInfo[] info = AccountDetailController.getAccountInfoList();
        Test.stopTest();
        Assert.areEqual(Name, info[0].name);
        
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
        String searchString = '500';
        
        Test.startTest();
        AccountDetailController.AccountInfo[] info = AccountDetailController.SearchBySumOfOpportunities(searchString);
        Test.stopTest();
        Assert.areEqual('TestAccount', info[0].name);   
    }
    @IsTest
    static void testFailSearchBySumOfOpportunities(){
        String searchString = '45';
        
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
    @isTest
    static void getOpportunityProduct(){
        Opportunity testOp = [SELECT ID FROM OPPORTUNITY LIMIT 1];
        OpportunityLineItem[] testItems = [SELECT NAME FROM OPPORTUNITYLINEITEM Where OpportunityId = :testOp.Id];
        OpportunityLineItem[] resultedItems = AccountDetailController.getOpportunityProduct(testOp.Id);
        Assert.areEqual(testItems.size(), resultedItems.size());
    }
   
}