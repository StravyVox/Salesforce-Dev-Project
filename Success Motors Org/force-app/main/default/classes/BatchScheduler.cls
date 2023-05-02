global class BatchScheduler implements Schedulable {
    public Database.Batchable<sObject> BatchObject;
    public Boolean setBatchObject(string nameOfBatchClass){
        Type batchClassType = Type.forName(nameOfBatchClass);
        try{
            BatchObject = (Database.Batchable<sObject>)batchClassType.newInstance();
            return true;
        }
        catch(Exception e){
            System.debug('Error while trying to find batch apex class');
            return false;
        }
    }
    
   global void execute(SchedulableContext SC) {
      if(BatchObject!=null){
        Database.executeBatch(BatchObject);
      }
   }
}