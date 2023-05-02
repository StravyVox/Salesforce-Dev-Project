@isTest
public class PaymentWebService_Test {
    @IsTest
    static void testCreatePayment(){
        String testPayment = '{"payments":[{"Opportunity":"GomelSaleo-","Amount":1000,"FirstName":"DD","LastName":"Payer"}]}';
        Test.startTest();
        RestRequest request = new RestRequest();
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf(testPayment);
        request.requestURI='https://successmotors42-dev-ed.develop.my.salesforce.com/services/apexrest/Payments';
        RestContext.request = request;
            List<Id> resultOfInput = PaymentWebService.createPayment();
        Test.stopTest();
        System.assert(resultOfInput.size()==1);
    }
}