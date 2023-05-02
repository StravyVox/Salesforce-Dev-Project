trigger PaymentTrigger on Payment__c (after insert, after update) {
   // Map<string,Payment__c> Opportunities = new List<string>();
    List<Opportunity> checkedOpportunities = new List<Opportunity>();
    Map<string, Decimal> paymentList = new Map<String,Decimal>();
    List<Task> scheduledTasks = new List<Task>();
    for (Payment__c payment : [SELECT OpportunityName__c, Amount__c FROM Payment__c]){
        if(paymentList.containsKey(payment.OpportunityName__c)){
            Decimal newValue = paymentList.get(payment.OpportunityName__c)+payment.Amount__c;
            paymentList.put(payment.OpportunityName__c,newValue); 
        }
        else{
            paymentList.put(payment.OpportunityName__c,payment.Amount__c);
        }
    }
    For(Opportunity op: [SELECT ID,Name, StageName, Amount,(Select Contact.OwnerId from OpportunityContactRoles WHERE isPrimary = true) from Opportunity Where Name in :paymentList.keySet()]){
        if(paymentList.get(op.Name)>=op.Amount){
            op.StageName = 'Fully Paid';
            checkedOpportunities.add(op);
            Task paidTask = new Task();
            paidTask.Priority = 'High';
            paidTask.Status = 'Not started';
            paidTask.Subject = 'Delivery of goods';
            paidTask.IsReminderSet = true;
            Datetime scheduledDate = Datetime.newInstance(Date.today().addDays(2),Time.newInstance(10, 0,0,0));
            paidTask.ReminderDateTime = scheduledDate;
            paidTask.OwnerId = op.OpportunityContactRoles[0].Contact.OwnerId; 
            paidTask.WhatId = op.Id;
            System.debug(paidTask.OwnerId);
            System.debug(paidTask.Status);
            scheduledTasks.add(paidTask);
        }
        else{
            op.StageName = 'Partially Paid';
            checkedOpportunities.add(op);
        }
    }
    update checkedOpportunities;
    insert scheduledTasks;
}
