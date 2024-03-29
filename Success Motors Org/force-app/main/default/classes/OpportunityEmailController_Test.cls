@isTest
public class OpportunityEmailController_Test {
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
            ContactId=testCon.Id, 
            Invoice_Number__c = 'INV-000115'
            );
        insert testOpportunity;
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        System.runAs(
            new User(Alias = 'standt', Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = p.id,
            TimeZoneSidKey='America/Los_Angeles',
             UserName='TestN4341124145663bbfdsxxame@gmail.com')) {
            EmailTemplate templateToTest = new EmailTemplate(
                Name='TestTemp',
                DeveloperName='TestUniqueName',
                Body='TestBody',
                htmlvalue='TestBody?body=approvedmailto:',
                Subject='TestSubject',
                TemplateType='custom',
                FolderId='0052w00000FSPQXAA5'
            );
            insert templateToTest;
        }
    }
    @IsTest
    static void testReturnRoleAccount() {
        Opportunity op = [SELECT Id, Name From Opportunity Where StageName='Prospecting' LIMIT 1];
        String expected = 'TestContact Test';
        Test.startTest();
           Contact result = (Contact)JSON.deserialize(OpportunityEmailController.returnPrimaryRoleAccount(op.Id), Contact.class); 
        Test.stopTest();
        Assert.areEqual(expected, result.Name);
    }
    @IsTest
    static void testReturnTemplateSubject() {
        Opportunity op = [SELECT Id, Name,Invoice_Number__c From Opportunity Where StageName='Prospecting' LIMIT 1];
        String expected = 'TestSubject'+' '+op.Invoice_Number__c;
        Test.startTest();
            String resultstring = OpportunityEmailController.returnTemplateSubject(op.Id, 'TestTemp');
        Test.stopTest();
        Assert.areEqual(expected, resultstring);
    }
    @IsTest
    static void testReturnTemplateBody() {
        Opportunity op = [SELECT Id, Name,Invoice_Number__c From Opportunity Where StageName='Prospecting' LIMIT 1];
        String expected = 'body=approved&subject=';
        Test.startTest();
          String result = OpportunityEmailController.returnTemplateBody(op.Id,'TestTemp');
          System.debug(result);
        Test.stopTest();
        System.assert(result.contains(expected));
    }
    @IsTest
    static void testSendEmail() {
        Opportunity op = [SELECT Id, Name,Invoice_Number__c From Opportunity Where StageName='Prospecting' LIMIT 1];
        OpportunityEmailController.EmailWrapper testWrapper = new OpportunityEmailController.EmailWrapper();
        testWrapper.opportunityId=op.id;
        testWrapper.toAddress=new List<String>{'stravyvox@gmail.com'};
        testWrapper.subject='TestSubject';
        testWrapper.body='TestBody';
        Integer expected = 1;
        Test.startTest();
          Integer result = OpportunityEmailController.SendMail(JSON.serialize(testWrapper));
        Test.stopTest();
        Assert.areEqual(expected, result);
    }
}