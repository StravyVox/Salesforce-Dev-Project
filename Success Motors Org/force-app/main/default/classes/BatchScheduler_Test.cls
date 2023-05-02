@isTest
public class BatchScheduler_Test {
    
    @IsTest
    static void testForBatching(){
        BatchScheduler sch = new BatchScheduler();
        sch.setBatchObject('BirthdayMassEmailSender');
        String cron = '0 0 0 * * ?';
        Test.startTest();
        String jobID = System.schedule('Birthday Opp Owners', cron, sch);
        CronTrigger triggerToCheck = [SELECT NextFireTime,TimesTriggered, CronExpression FROM CronTrigger WHERE Id = :jobID];
        System.assertEquals(cron,triggerToCheck.CronExpression);
        System.assert(triggerToCheck.TimesTriggered == 0);
        System.assert(triggerToCheck.NextFireTime.date() == Date.today().addDays(1));
        Test.stopTest();
    }
}