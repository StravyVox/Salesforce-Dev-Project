import { LightningElement,api} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import AccountDetailModal from 'c/accountDetailModal';
export default class AccountDetailTable extends NavigationMixin(LightningElement){
    @api totalOpportunities = ''; 
    showModal = true;
    viewOpportunity(event){
        console.log('viewOp is activated');
        console.log(event.target.dataset.id);
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