import { api,track } from 'lwc';
import LightningModal from 'lightning/modal';
import CreateDocument from '@salesforce/apex/OpportunityPDFController.CreateDocument';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class generateInvoice extends LightningModal {

    @api content;
    @api loaded = false;
    @track linkPDF = '/apex/OpportunityPDF?id='+this._recordId;


    @track _recordId;

    @api set recordId(value) {
        this._recordId = value;
        this.linkPDF = '/apex/OpportunityPDF?id='+this._recordId;
        this.loaded = true;
    }

    get recordId() {
        return this._recordId;
    }
    closeAction() {
        
        this.dispatchEvent(new CloseActionScreenEvent());
    }
    generateInvoice(){
        CreateDocument({OpportunityID: this.recordId}).then(
            result=>{
                console.log(result);
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
        
        console.log('SendMessage done');
        console.log('Result is ' + result);
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