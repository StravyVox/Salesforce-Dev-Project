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
                    acc.Name + ' with ' + acc.opportunities.size() + ' opportunities',
                    acc.Id,
                    acc.Name,
                    acc.opportunities
                );
                result.add(info);
            }
            return result;
        }
        catch(Exception e){
            return null;
        }
    }
    @AuraEnabled (cacheable=true)
    public static List<AccountInfo> getAccountInfoList(){
        try {
            List<Account> accounts = [SELECT ID, NAME, (SELECT ID, NAME, CreatedDate, CloseDate, Amount FROM OPPORTUNITIES) FROM ACCOUNT];
            List<AccountInfo> result = returnInfo(accounts);
            return result;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled (cacheable=true)
    public static List<AccountInfo> SearchByNameOfAccount(String searchString){
        try {
            String likeSearch =  '%'+searchString+'%';
            List<Account> accounts = [SELECT ID, NAME, (SELECT ID, NAME, CreatedDate, CloseDate, Amount FROM OPPORTUNITIES) FROM ACCOUNT WHERE Name LIKE :likeSearch];
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
    public static List<AccountInfo> SearchBySumOfOpportunities(String searchString){
        try {
            Integer sum = Integer.valueOf(searchString);
            List<AggregateResult> accounts = [SELECT COUNT(ID), Account.Id FROM Opportunity group by Account.Id HAVING COUNT(ID) = :sum];
            List<String> accountIds = new List<String>();
            for(AggregateResult acc : accounts){
                 accountIds.add(String.valueOf(acc.get('Id')));
            }
            List<Account> resultAccounts = [SELECT ID, NAME, (SELECT ID, NAME, CreatedDate, CloseDate, Amount FROM OPPORTUNITIES) FROM ACCOUNT WHERE ID IN :accountIds];
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
            Account acc = [SELECT ID, NAME, (SELECT ID, NAME, CreatedDate, CloseDate, Amount FROM OPPORTUNITIES) FROM Account WHERE Id = :Id LIMIT 1];
            AccountInfo result = new AccountInfo(
                        acc.Name + ' with ' + acc.opportunities.size() + ' opportunities',
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