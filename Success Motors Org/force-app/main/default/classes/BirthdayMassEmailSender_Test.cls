@isTest
public class BirthdayMassEmailSender_Test {
    @TestSetup
    static void makeData(){
        Contact mainContact = new Contact(
            LastName = 'testCotntact111',
            Birthdate = Date.today(),
            Email = 'testingsupmail11@gmail.testcom'
        );
        insert mainContact;
    }
    @IsTest
    static void testSenderSuccess(){
        Contact testedContact = [SELECT Id,Email,LastName, Birthdate FROM Contact WHERE LastName = 'testCotntact111' LIMIT 1];
        Test.startTest();
            BirthdayMassEmailSender sender = new BirthdayMassEmailSender();
            Id batchInstanceId = Database.executeBatch(sender);
        Test.stopTest();
            AsyncApexJob job = [SELECT Status FROM AsyncApexJob Where Id =:batchInstanceId];
            System.assert(job.Status == 'Completed');
    }
} 