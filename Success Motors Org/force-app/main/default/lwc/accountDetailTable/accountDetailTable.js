import { LightningElement,api} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import AccountDetailModal from 'c/accountDetailModal';
import TitleLabel from '@salesforce/label/c.AccountDetailTable_Title'
export default class AccountDetailTable extends NavigationMixin(LightningElement){
    label=TitleLabel
    @api totalOpportunities = ''; 
    showModal = true;
    viewOpportunity(event){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                "recordId": event.target.dataset.id,
                "objectApiName": "Opportunity",
                "actionName": "view"
            },
        });
    }
    openModal(event){
        let opportunityId = event.target.dataset.id;
        AccountDetailModal.open({
            size:'large',
            opId:opportunityId
        });
    }
}