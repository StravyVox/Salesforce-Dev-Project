import { api, track } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import LightningModal from 'lightning/modal';
import getOpportunityProduct from '@salesforce/apex/AccountDetailController.getOpportunityProduct';
export default class AccountDetailModal extends LightningModal {
    opportunityId = '';
    opportunityProducts = '';
    cols = [
        {label:'Name', fieldName:'Name' , type:'text'},
        {label:'Quantity', fieldName:'Quantity' , type:'text'} ,
        {label:'Total Price', fieldName:'TotalPrice' , type:'text'} ,
              
    ]
    @api set opId(data){
        if(data){
            console.log(data);
            this.opportunityId = data;
            this.setInfo();
        }
    }
    get opId(){
        return this.opportunityId;
    }
    setInfo(){
        getOpportunityProduct({OpportunityId: this.opportunityId}).then(result=>{
            console.log(result);
            this.opportunityProducts = result;
        }).catch(error=>{
            console.log(error.message);
        })
    }
    closeAction() {   
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}