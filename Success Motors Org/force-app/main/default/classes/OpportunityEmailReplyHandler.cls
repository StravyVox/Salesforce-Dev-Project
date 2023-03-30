global class OpportunityEmailReplyHandler implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        System.debug('OpportunityEmalReplyHandler was activated');

        if(email.subject.length()>0){
            System.debug('Email.subject is greater than 0 '+email.subject);
            String regExPattern='INV-[0-9]+';
            String InvoiceNumber = FindStringByPattern(regExPattern, email.subject);
            String resultOfSet = SetResultOfOpportunity(InvoiceNumber, email);
            if(resultOfSet.length()>0){
                result.success=false;
                result.message=resultOfSet;
            }
            else {
                result.success=true;
            }
        }
        else{
            System.debug('Email has no subject');
            String regExPattern='INV-[0-9]+';            
            String InvoiceNumber = FindStringByPattern(regExPattern, email.subject);
            String resultOfSet = SetResultOfOpportunity(InvoiceNumber, email);
            if(resultOfSet.length()>0){
                result.success=false;
                result.message=resultOfSet;
            }
            else {
                result.success=true;
            }
        }

        return result;
    }
    
    @TestVisible private String FindStringByPattern(String regularExp, String searchString){
        Pattern regExpPattern = Pattern.compile(regularExp);
        Matcher regExpMatcher = regExpPattern.matcher(searchString);
        if(regExpMatcher.find()){
            System.debug('string has matches');
            String result = regExpMatcher.group(0);
            return result;
        }
        else {
            System.debug('No matches in string found');
            return '';
        }
    }
    @TestVisible private String SetResultOfOpportunity(String OpportunityInvoiceNumber,Messaging.InboundEmail email){
        try{
            Opportunity op = [SELECT ID, NAME, StageName FROM Opportunity Where Invoice_Number__c =:OpportunityInvoiceNumber LIMIT 1];
            String PatternApproved = '\\bapproved\\b';
            String PatternRejected = '\\brejected\\b';
            String approvedResult = FindStringByPattern(PatternApproved, email.plainTextBody.toLowerCase());
            String rejectedResult = FindStringByPattern(PatternRejected, email.plainTextBody.toLowerCase());
            if(approvedResult.length()>0){
                Schema.DescribeFieldResult fields = Opportunity.StageName.getDescribe();
                List<Schema.PicklistEntry> opportunityPickList = fields.getPicklistValues();
                for(Integer i=0;i<opportunityPickList.size();i++)
                {
                    if(opportunityPickList[i].getValue() == op.StageName)
                    { 
                        op.StageName =opportunityPickList[i+1].getValue();
                        break;
                    }
                }
                update op;
                return '';
            }
            else if(rejectedResult.length()>0){
                op.StageName='Closed Lost';
                update op;  
                return ''; 
            }
            else{
                return 'Sorry, but we couldn\'t find any approved or rejected message in your email';
            }
        }
        catch(System.QueryException e){
            return e.getMessage();
        }
   } 
}