trigger PaymentTrigger on Payment__c (after insert, after update) {
    List<Opportunity> checkedOpportunities = new List<Opportunity>();
    Map<string, Decimal> paymentList = new Map<String,Decimal>();
    List<Task> scheduledTasks = new List<Task>();
    paymentList = PaymentTriggerController.getPaymentList();
    if(paymentList.size()>0){
        checkedOpportunities = PaymentTriggerController.updateOpportunities(paymentList);
    }
    if(checkedOpportunities.size()>0){
        scheduledTasks = PaymentTriggerController.setTasksForOpportunities(checkedOpportunities);
        update checkedOpportunities;
        if(scheduledTasks.size()>0){
            insert scheduledTasks;
        }
    }
}
