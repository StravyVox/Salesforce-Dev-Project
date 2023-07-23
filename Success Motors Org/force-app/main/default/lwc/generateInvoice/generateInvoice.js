import { api,track } from 'lwc';
import LightningModal from 'lightning/modal';
import createDocument from '@salesforce/apex/OpportunityPDFController.createDocument';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import TitleLabel from '@salesforce/label/c.GenerateInvoice_Title'
export default class generateInvoice extends LightningModal {
    label = TitleLabel;
    @api content;
    @api loaded = false;
    @track linkPDF = '/apex/SMotors__OpportunityPDF?id='+this._recordId;
    @track _recordId;
    @api set recordId(value) {
        this._recordId = value;
        this.linkPDF = '/apex/SMotors__OpportunityPDF?id='+this._recordId;
        this.loaded = true;
    }
    get recordId() {
        return this._recordId;
    }

    closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
    generateInvoice(){
        createDocument({OpportunityID: this.recordId}).then(
            result=>{
                this.closeAction();
                this.sendMessage(result);
            }
        ).catch(error=>{
            console.log(error);
            this.error = error;
            this.closeAction();
            this.sendMessage(error);
        });
    }

    sendMessage(result){
        switch(result){
            case 1:
                var eventMessage = new ShowToastEvent({
                    title:'Success',
                    variant: 'success',
                    message:'Successfully updated'
                });
                this.dispatchEvent(eventMessage);
                break;
            case 2:
                var eventMessage = new ShowToastEvent({
                    title:'Success',
                    variant: 'success',
                    message:'Successfully added'
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