import { api,track } from 'lwc';
import LightningModal from 'lightning/modal';
import { NavigationMixin } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import returnPrimaryRoleAccount from '@salesforce/apex/OpportunityEmailController.returnPrimaryRoleAccount';
import returnTemplateBody from '@salesforce/apex/OpportunityEmailController.returnTemplateBody';
import returnTemplateSubject from '@salesforce/apex/OpportunityEmailController.returnTemplateSubject';
import sendMail from '@salesforce/apex/OpportunityEmailController.sendMail';
import getAttachedDocumentID from '@salesforce/apex/OpportunityPDFController.getAttachedDocumentID';

export default class SendEmail extends NavigationMixin(LightningModal) {
    @track subject = 'Loading...';
    @track contactRole = {Email: 'Loading...', Name: 'Loading...'};
    @track emailBody = 'Loading...';
    @track loaded = false;
    @track linkPDF = '/apex/OpportunityPDF?id='+this.recordId;
    @track _recordId;
    documentID;
    
    @api set recordId(value) {
        this._recordId = value;

        console.log('Current recordId is '+ value);
        returnPrimaryRoleAccount({OpportunityID: value}).then(
            result=>{
                this.contactRole =  JSON.parse(result);
                console.log('Contact role is '+ this.contactRole.Email);
            }
        ).catch(
            error=>{
                this.closeAction(-1);
            }
        );
        returnTemplateSubject({OpportunityID: value, TemplateName: "Opportunity Bill"}).then(
            result=>{ 
                console.log('Template subject is '+result);
                this.subject = result;
            }
        ).catch(
            error=>{
                this.closeAction(-1);
            }
        );
        returnTemplateBody({OpportunityID: value,TemplateName: "Opportunity Bill"}).then(
            result=>{
                console.log('Template body is '+result);
                
                this.emailBody = result;
            }
        ).catch(
            error=>{
                this.closeAction(-1);
            }
        );
        getAttachedDocumentID({OpportunityID: this._recordId}).then(result=>{
            if(result!=null)
            {
                console.log("GetAttchedDocumentId is: "+result);
                this.documentID = result;
            }
            else{
                console.log("Returned null");
            }
        })
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
        sendMail({emailDetail: JSON.stringify(emailBody)}).then(
            result=>{
                this.closeAction(result);
            }
        ).catch(error=>{
            this.closeAction(-1);
        });
    }

    loadInfo(){
        console.log("Activated loadInfo");
        console.log("DocId is: "+this.documentID);
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview',
            },
            state:{
                selectedRecordId: this.documentID
            }
        })
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