@RestResource(urlMapping='/Payments/*')
global with sharing class PaymentWebService {
    private class PaymentWrapper {
        public string Opportunity;
        public Decimal Amount;
        public string FirstName;
        public string LastName; 
    }
    private class ListPaymentsWrapper{
        public List<PaymentWrapper> payments;
    }
    @HttpPost
    global static List<ID> createPayment(){
        RestRequest request = RestContext.request;
        String jsonString = request.requestBody.toString();
        System.debug('Json string is: '+jsonString);
        
        ListPaymentsWrapper paymentsList = (ListPaymentsWrapper)JSON.deserialize(jsonString, ListPaymentsWrapper.class);
        List<PaymentWrapper> payments = paymentsList.payments;
        List<Payment__c> result = new List<Payment__c>();
        List<ID> insertedIDs = new List<ID>();
        for(PaymentWrapper payInfo: payments){
            Payment__c payment = new Payment__c(
                OpportunityName__c = payInfo.Opportunity,
                Amount__c = payInfo.Amount,
                FirstName__c = payInfo.FirstName,
                LastName__c = payInfo.LastName
            );
            result.add(payment);
        }
        Database.SaveResult[] resultOfInsert = Database.insert(result);
        for(Database.SaveResult saveRes : resultOfInsert){
            insertedIDs.add(saveRes.getId());
        }
        return insertedIDs;
    }
}