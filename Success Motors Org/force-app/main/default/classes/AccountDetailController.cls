public with sharing class AccountDetailController {
    
    @TestVisible Class AccountInfo {
        @AuraEnabled
        public String value;
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public List<Opportunity> opportunities;
        
        public AccountInfo(String value, String id, String name, List<Opportunity> opportunitites){
            this.value = value;
            this.id = id;
            this.name = name;
            this.opportunities = opportunitites;
        }
    }
    private static List<AccountInfo> returnInfo(List<Account> accounts){
        try {
            List<AccountInfo> result = new List<AccountInfo>();
            for (Account acc : accounts) {
                AccountInfo info = new AccountInfo(
                    acc.Name + ' with ' + acc.opportunities.size() + ' closed won opportunities with total amount '+totalAmount(acc.opportunities),
                    acc.Id,
                    acc.Name,
                    acc.opportunities
                );
                if(acc.opportunities.size()>0){
                    result.add(info);
                }
            }
            return result;
        }
        catch(Exception e){
            return null;
        }
    }
    private static Decimal totalAmount(List<Opportunity> oppportunities){
        Decimal totalAmount = 0;
        for(Opportunity op : oppportunities){
            totalAmount+=op.Amount;
        }
        return totalAmount;
    }
    @AuraEnabled (cacheable=true)
    public static List<AccountInfo> getAccountInfoList(){
        try {
            List<Account> accounts = [SELECT ID, NAME, (SELECT ID, NAME, CreatedDate, CloseDate, Amount FROM OPPORTUNITIES WHERE StageName = 'Closed Won') FROM ACCOUNT];
            List<AccountInfo> result = returnInfo(accounts);
            return result;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled (cacheable=true)
    public static List<AccountInfo> searchByNameOfAccount(String searchString){
        try {
            String likeSearch =  searchString+'%';
            List<Account> accounts = [SELECT ID, NAME, (SELECT ID, NAME, CreatedDate, CloseDate, Amount FROM OPPORTUNITIES WHERE StageName = 'Closed Won') FROM ACCOUNT WHERE Name LIKE :likeSearch];
            if(!accounts.isEmpty()){
                List<AccountInfo> result = returnInfo(accounts);
                return result;
            }
            else{
                return null;
            }
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled (cacheable=true) 
    public static List<AccountInfo> searchBySumOfOpportunities(String searchString){
        try {
            String likeSearch =  searchString+'.*';
            List<String> accountIds = new List<String>();
            for(AggregateResult acc : [SELECT SUM(Amount), Account.Id FROM Opportunity WHERE StageName = 'Closed Won' group by Account.Id]){
                if(Pattern.matches(likeSearch, String.valueOf(acc.get('expr0')))){
                    accountIds.add(String.valueOf(acc.get('Id')));
                }
            }
            List<Account> resultAccounts = [SELECT ID, NAME, (SELECT ID, NAME, CreatedDate, CloseDate, Amount FROM OPPORTUNITIES WHERE StageName = 'Closed Won') FROM ACCOUNT WHERE ID IN :accountIds];
            if(!resultAccounts.isEmpty()){
                List<AccountInfo> result = returnInfo(resultAccounts);
                return result;
            }
            else{
                return null;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled (cacheable=true)
    public static AccountInfo getAccount(String Id){
        try {
            Account acc = [SELECT ID, NAME, (SELECT ID, NAME, CreatedDate, CloseDate, Amount FROM OPPORTUNITIES WHERE StageName = 'Closed Won') FROM Account WHERE Id = :Id LIMIT 1];
            AccountInfo result = new AccountInfo(
                        acc.Name + ' with ' + acc.opportunities.size() + ' closed won opportunities with total amount '+totalAmount(acc.opportunities),
                        acc.Id,
                        acc.Name,
                        acc.opportunities
                    );
            return result;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled (cacheable=true)
    public static List<OpportunityLineItem> getOpportunityProduct(String OpportunityId){
        try {
            List<OpportunityLineItem> products = [SELECT ID, NAME, Quantity, TotalPrice FROM OpportunityLineItem WHERE OpportunityId = :OpportunityId];
            return products;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
}