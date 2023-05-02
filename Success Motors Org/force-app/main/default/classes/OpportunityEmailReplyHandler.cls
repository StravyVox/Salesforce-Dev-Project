global class OpportunityEmailReplyHandler implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        if(email.subject.length()>0){
            String regExPattern='INV-[0-9]+';
            String invoiceNumber = findStringByPattern(regExPattern, email.subject);
            String resultOfSet = setResultOfOpportunity(invoiceNumber, email);
            if(resultOfSet.length()>0){
                result.success=false;
                result.message=resultOfSet;
            }
            else {
                result.success=true;
            }
        }
        else{
            String regExPattern='\\bINV-[0-9]+\\b';            
            String invoiceNumber = findStringByPattern(regExPattern, email.htmlBody);
            String resultOfSet = setResultOfOpportunity(invoiceNumber, email);
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
    
    @TestVisible private String findStringByPattern(String regularExp, String searchString){
        Pattern regExpPattern = Pattern.compile(regularExp);
        Matcher regExpMatcher = regExpPattern.matcher(searchString);
        if(regExpMatcher.find()){
            String result = regExpMatcher.group(0);
            return result;
        }
        else {
            System.debug('No matches in string found');
            return '';
        }
    }
    @TestVisible private String setResultOfOpportunity(String OpportunityInvoiceNumber,Messaging.InboundEmail email){
        try{
            Opportunity op = [SELECT ID, NAME, StageName FROM Opportunity Where Invoice_Number__c =:OpportunityInvoiceNumber LIMIT 1];
            String patternApproved = '\\bapproved\\b';
            String patternRejected = '\\brejected\\b';
            String approvedResult = findStringByPattern(patternApproved, email.htmlBody.toLowerCase());
            String rejectedResult = findStringByPattern(patternRejected, email.htmlBody.toLowerCase());
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