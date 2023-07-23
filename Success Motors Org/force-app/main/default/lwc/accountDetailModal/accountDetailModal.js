import { api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import LightningModal from 'lightning/modal';
import getOpportunityProduct from '@salesforce/apex/AccountDetailController.getOpportunityProduct';
import TitleLabel from '@salesforce/label/c.AccountDetailModal_Title'
export default class AccountDetailModal extends LightningModal {
    label = TitleLabel;
    opportunityId = '';
    opportunityProducts = '';
    cols = [
        {label:'Name', fieldName:'Name' , type:'text'},
        {label:'Quantity', fieldName:'Quantity' , type:'text'} ,
        {label:'Total Price', fieldName:'TotalPrice' , type:'text'} ,  
    ]
    @api set opId(data){
        if(data){
            this.opportunityId = data;
            this.setInfo();
        }
    }
    get opId(){
        return this.opportunityId;
    }
    setInfo(){
        getOpportunityProduct({OpportunityId: this.opportunityId}).then(result=>{
            this.opportunityProducts = result;
        })
        .catch(error=>{})
    }
    closeAction() {   
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}