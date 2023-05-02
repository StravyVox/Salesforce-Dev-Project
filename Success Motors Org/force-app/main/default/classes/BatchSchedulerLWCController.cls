public with sharing class BatchSchedulerLWCController {
    @AuraEnabled
    public static Boolean trySetBatch(String BatchName){
        BatchScheduler scheduler = new BatchScheduler();
        return scheduler.setBatchObject(batchName);
    }
    @AuraEnabled
    public static Boolean isJobAlreadyQueued(String jobName){
        try{
            AsyncApexJob job = [SELECT ApexClass.Name FROM AsyncApexJob WHERE CronTrigger.CronJobDetail.Name = :jobName LIMIT 1];
            return true;
        }
        catch(Exception e){
            System.debug('Is jobQueued active and false result returned');
            return false;
        }

    }
    @AuraEnabled
    public static Boolean abortJob(String jobName){
        try{
            AsyncApexJob job = [SELECT Id, ApexClass.Name, CronTrigger.Id FROM AsyncApexJob WHERE CronTrigger.CronJobDetail.Name = :jobName LIMIT 1]; 
            System.abortJob(job.CronTrigger.Id);
            return true;
        }
        catch(Exception e){
            return false;
        }

    }
    @AuraEnabled
    public static Boolean runJobOnce(String batchName,String jobName){
        try{
            BatchScheduler scheduler = new BatchScheduler();
            scheduler.setBatchObject(batchName);
            System.scheduleBatch(scheduler.BatchObject,jobName, 0);
            return true;
        }
        catch(Exception e){
            return false;
        }
    }
    @AuraEnabled
    public static Boolean scheduleJob(String batchName,String jobName, String cronExp){
        try{
            BatchScheduler scheduler = new BatchScheduler();
            scheduler.setBatchObject(batchName);
            System.schedule(jobName, cronExp, scheduler);
            return true;
        }
        catch(Exception e){
            return false;
        }
    }
}