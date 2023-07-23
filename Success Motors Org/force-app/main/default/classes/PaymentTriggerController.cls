public with sharing class PaymentTriggerController {
    public static Map<String, Decimal> getPaymentList() {
        Map<String, Decimal> paymentList = new Map<String, Decimal>();
        for (Payment__c payment : [SELECT OpportunityName__c, Amount__c FROM Payment__c]){
            if(paymentList.containsKey(payment.OpportunityName__c)){
                Decimal newValue = paymentList.get(payment.OpportunityName__c)+payment.Amount__c;
                paymentList.put(payment.OpportunityName__c,newValue); 
            }
            else{
                paymentList.put(payment.OpportunityName__c,payment.Amount__c);
            }
        }
        return paymentList;
    }
    public static List<Opportunity> updateOpportunities(Map<String, Decimal> paymentList){
        List<Opportunity> checkedOpportunities = new List<Opportunity>();
        For(Opportunity op: [SELECT ID,Name, StageName, Amount,(Select Contact.OwnerId from OpportunityContactRoles WHERE isPrimary = true) from Opportunity Where Name in :paymentList.keySet()]){
            if(paymentList.get(op.Name)>=op.Amount){
                op.StageName = 'Fully Paid';
                checkedOpportunities.add(op);
            }
            else{
                op.StageName = 'Partially Paid';
                checkedOpportunities.add(op);
            }
        }
        return checkedOpportunities;
    }
    public static List<Task> setTasksForOpportunities(List<Opportunity> ops){
        List<Task> paidTasks = new List<Task>();
        for (Opportunity opportunity : ops){
            if(opportunity.StageName == 'Fully Paid'){
                Datetime scheduledDate = Datetime.newInstance(Date.today().addDays(2),Time.newInstance(10, 0,0,0));
                Task paidTask = new Task();
                paidTask.Priority = 'High';
                paidTask.Status = 'Not started';
                paidTask.Subject = 'Delivery of goods';
                paidTask.IsReminderSet = true; 
                paidTask.ReminderDateTime = scheduledDate;
                paidTask.OwnerId = opportunity.OpportunityContactRoles[0].Contact.OwnerId; 
                paidTask.WhatId = opportunity.Id;
                paidTasks.add(paidTask);
            }
        }
        return paidTasks;

    }
}