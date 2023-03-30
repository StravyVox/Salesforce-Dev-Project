import { api,track } from 'lwc';
import LightningModal from 'lightning/modal';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ReturnPrimaryRoleAccount from '@salesforce/apex/OpportunityEmailController.ReturnPrimaryRoleAccount';
import ReturnTemplateBody from '@salesforce/apex/OpportunityEmailController.ReturnTemplateBody';
import ReturnTemplateSubject from '@salesforce/apex/OpportunityEmailController.ReturnTemplateSubject';
import SendMail from '@salesforce/apex/OpportunityEmailController.SendMail';

export default class SendEmail extends LightningModal {
    @track subject = 'Loading...';
    @track contactRole = {Email: 'Loading...', Name: 'Loading...'};
    @track emailBody = 'Loading...';
    @track loaded = false;
    @track linkPDF = '/apex/OpportunityPDF?id='+this.recordId;
    
    @track _recordId;

    @api set recordId(value) {
        this._recordId = value;

        console.log('Current recordId is '+ value);
        ReturnPrimaryRoleAccount({OpportunityID: value}).then(
            result=>{
                this.contactRole =  JSON.parse(result);
                console.log('Contact role is '+ this.contactRole.Email);
            }
        ).catch(
            error=>{
                this.closeAction(-1);
            }
        );
        ReturnTemplateSubject({OpportunityID: value, TemplateName: "Opportunity_Bill_1678894162036"}).then(
            result=>{ 
                console.log('Template subject is '+result);
                this.subject = result;
            }
        ).catch(
            error=>{
                this.closeAction(-1);
            }
        );
        ReturnTemplateBody({OpportunityID: value,TemplateName: "Opportunity_Bill_1678894162036"}).then(
            result=>{
                console.log('Template body is '+result);
                this.emailBody = result;
            }
        ).catch(
            error=>{
                this.closeAction(-1);
            }
        );
    }

    get recordId() {
        return this._recordId;
    }
        
    emailBodyChanged(event){
        this.emailBody = event.target.value;
    }
    emailChanged(event){
        this.contactRole.Email = event.target.value;
    }
    sendEmail(){
        var emailBody = {
            opportunityId: this._recordId,
            toAddress: [this.contactRole.Email],
            subject: this.subject,
            body: this.emailBody
        };
        SendMail({emailDetail: JSON.stringify(emailBody)}).then(
            result=>{
                this.closeAction(result);
            }
        ).catch(error=>{
            this.closeAction(-1);
        });
    }

    loadInfo(){
        this.linkPDF = '/apex/OpportunityPDF?id='+this.recordId;
        this.loaded = true;
    }
    closeAction(result) {   
        this.dispatchEvent(new CloseActionScreenEvent());
        this.sendMessage(result);
    }
    sendMessage(result){
        console.log('SendMessage done');
        console.log('Result is ' + result);
        switch(result){
            case 1:
                var eventMessage = new ShowToastEvent({
                    title:'Success',
                    variant: 'success',
                    message:'Email was send'
                });
                this.dispatchEvent(eventMessage);
                break;
            default:
                var eventMessage = new ShowToastEvent({
                    title: 'Error',
                    variant: 'error',
                    message: 'Something went wrong'
                    });
                    this.dispatchEvent(eventMessage);
                break;
            
        }
    }
}