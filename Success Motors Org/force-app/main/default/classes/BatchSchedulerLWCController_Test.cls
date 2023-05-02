@isTest
public class BatchSchedulerLWCController_Test {
    @IsTest
    static void testTrySetBatch(){
        String testingFailName = 'helloworld';
        String testSuccessName = 'BirthdayMassEmailSender';
        Boolean failResult;
        Boolean successResult;
        Test.startTest();
            failResult = BatchSchedulerLWCController.trySetBatch(testingFailName);
            successResult = BatchSchedulerLWCController.trySetBatch(testSuccessName);
        Test.stopTest();
        System.assert(failResult == false);
        System.assert(successResult == true);
    }
    @IsTest
    static void testisJobAlreadyQueued(){
        String batchName = 'BirthdayMassEmailSender';
        String jobName = 'testJob';
        String failJobName = 'failJob';
        String cronExpression = '0 0 0 * * ?';
        Boolean resultOfCreating;
        Boolean resultOfTestingForScheduledJob;
        Boolean failResultOfTestingForScheduledJob;
        
        Test.startTest();
            resultOfCreating = BatchSchedulerLWCController.scheduleJob(batchName, jobName, cronExpression);
            resultOfTestingForScheduledJob = BatchSchedulerLWCController.isJobAlreadyQueued(jobName);
            failResultOfTestingForScheduledJob = BatchSchedulerLWCController.isJobAlreadyQueued(failJobName);
        Test.stopTest();
        System.assert(resultOfCreating == true);
        System.assert(resultOfTestingForScheduledJob == true);
        System.assert(failResultOfTestingForScheduledJob == false);
    }
    @IsTest
    static void testRunJobOnce(){
        String batchName = 'BirthdayMassEmailSender';
        String jobName = 'testJob';
        Boolean resultOfCreating;
        Boolean resultOfFailCreating;
        
        Test.startTest();
            resultOfCreating = BatchSchedulerLWCController.runJobOnce(batchName, jobName);
            resultOfFailCreating = BatchSchedulerLWCController.runJobOnce(batchName, jobName);
        Test.stopTest();
        System.assert(resultOfCreating == true);
        System.assert(resultOfFailCreating == false);

    }
    @IsTest
    static void testAbortJob(){
        String batchName = 'BirthdayMassEmailSender';
        String jobName = 'testJob';
        String cronExp = '0 0 0 * * ?';
        Boolean resultOfCreating;
        Boolean resultOfAborting;
        Test.startTest();
            resultOfCreating = BatchSchedulerLWCController.scheduleJob(batchName, jobName, cronExp);
            resultOfAborting = BatchSchedulerLWCController.abortJob(jobName);
        Test.stopTest();
        System.assert(resultOfCreating == true);
        System.assert(resultOfAborting == true);
        
    }
    @IsTest
    static void testScheduleJob(){
        String batchName = 'BirthdayMassEmailSender';
        String jobName = 'testJob';
        String secondJobName = 'testJob';
        String cronExp = '0 0 0 * * ?';
        String failCronExp = '0 0 0 * * *';
        Boolean resultOfCreating;
        Boolean resultOfFailCreating;
        Test.startTest();
            resultOfCreating = BatchSchedulerLWCController.scheduleJob(batchName, jobName, cronExp);
            resultOfFailCreating = BatchSchedulerLWCController.scheduleJob(batchName, secondJobName, failCronExp);
        Test.stopTest();
        System.assert(resultOfCreating == true);
        System.assert(resultOfFailCreating == false);
        
    }
}