public with sharing class BirthdayMassEmailSender implements Database.Batchable<sObject>,Database.Stateful{
    private EmailTemplate template;
    private List<ID> idListOfContacts;
    public BirthdayMassEmailSender() {
        this.template = [SELECT ID, NAME FROM EMAILTEMPLATE WHERE NAME = 'Happy Birthday Discount' LIMIT 1];
        this.idListOfContacts = new List<ID>();
    }
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator('SELECT Id, Birthdate FROM Contact');
    }
    public void execute(Database.BatchableContext BC, List<Contact> scope){
        for(Contact testCon : scope){
            if(testCon.Birthdate!=null){
                if(testCon.Birthdate.isSameDay(Date.today())){
                    this.idListOfContacts.add(testCon.Id);
                    System.debug(this.idListOfContacts);
                }
            }
        }
    }
    public void finish(Database.BatchableContext BC){
        if(this.idListOfContacts.size()>0){
            Messaging.MassEmailMessage mail = new Messaging.MassEmailMessage();
            mail.targetobjectids = this.idListOfContacts;
            mail.templateid = this.template.Id;
            Messaging.sendEmail(new Messaging.MassEmailMessage[] { mail });
        }
    }
}
