public with sharing class AccountDetailController {
    
    @TestVisible Class AccountInfo {
        public String value;
        public String id;
        public String name;
        public List<Opportunity> opportunities;
        public AccountInfo(String value, String Id, String Name){
            this.value = value;
            this.id = Id;
            this.name = Name;
            this.opportunities = getOpportunities(Id);
        }
    }
    @AuraEnabled (cacheable=true)
    public static String getAccountsListJSON(){
        try {
            List<Account> accounts = [SELECT ID, NAME FROM Account];
            List<AccountInfo> result = new List<AccountInfo>();
            for (Account acc : accounts) {
                AccountInfo info = new AccountInfo(
                    acc.Name + ' with ' + getOpportunities(acc.Id).size() + ' opportunities',
                    acc.Id,
                    acc.Name
                );
                result.add(info);
            }
            return JSON.serialize(result);
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled (cacheable=true)
    public static String SearchByNameOfAccount(String searchString){
        try {
            String likeSearch =  '%'+searchString+'%';
            List<Account> accounts = [SELECT ID, NAME FROM Account WHERE Name LIKE :likeSearch];
            if(!accounts.isEmpty()){
                List<AccountInfo> result = new List<AccountInfo>();
                for (Account acc : accounts) {
                    AccountInfo info = new AccountInfo(
                        acc.Name + ' with ' + getOpportunities(acc.Id).size() + ' opportunities',
                        acc.Id,
                        acc.Name
                    );
                    result.add(info);
                }
                return JSON.serialize(result);
            }
            else{
                return null;
            }
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled (cacheable=true) 
    public static String SearchBySumOfOpportunities(String searchString){
        try {
           Integer sum = Integer.valueOf(searchString);
           List<AggregateResult> accounts = [SELECT COUNT(ID), Account.Id, Account.Name FROM Opportunity group by Account.Name, Account.Id HAVING COUNT(ID) = :sum];
           if(!accounts.isEmpty()){
                List<AccountInfo> result = new List<AccountInfo>();
                for (AggregateResult acc : accounts) {
                    AccountInfo info = new AccountInfo(
                        String.valueOf(acc.get('Name')) + ' with ' + String.valueOf(acc.get('expr0')) + ' opportunities',
                        String.valueOf(acc.get('Id')),
                        String.valueOf(acc.get('Name'))
                    );
                    result.add(info);
                }
                return JSON.serialize(result);
           }
           else{
                return null;
           }
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled (cacheable=true)
    public static String getAccount(String Id){
        try {
            Account acc = [SELECT ID, NAME FROM Account WHERE Id = :Id LIMIT 1];
            AccountInfo result = new AccountInfo(
                        acc.Name + ' with ' + getOpportunities(acc.Id).size() + ' opportunities',
                        acc.Id,
                        acc.Name
                    );
            return JSON.serialize(result);
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled (cacheable=true)
    public static List<Opportunity> getOpportunities(String accountId){
        try {
            List<Opportunity> opportunities = [SELECT ID, NAME, CreatedDate, CloseDate, Amount FROM Opportunity WHERE AccountId = :accountId];
            return opportunities;
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