import { LightningElement, wire,track,api } from 'lwc';
import getAccountInfoList from '@salesforce/apex/AccountDetailController.getAccountInfoList'
import getAccount from '@salesforce/apex/AccountDetailController.getAccount';
import SearchByNameOfAccount from '@salesforce/apex/AccountDetailController.SearchByNameOfAccount';
import SearchBySumOfOpportunities from '@salesforce/apex/AccountDetailController.SearchBySumOfOpportunities';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class AccountDetailLWC extends LightningElement {
    visibleAccounts;
    totalAccounts;
    _recordId;
    @track searchValue;
    @wire(getAccountInfoList) function ({data,error}) {
        if(data){
            console.log(data);
            this.totalAccounts =  data;
        }
        else{
            console.log('error');
            console.log(error);
        }
    }
    @api set recordId(data){
        if(data){
            this._recordId = data;
            getAccount({Id: this._recordId})
            .then(result=>{
                this.totalAccounts = '';
                this.visibleAccounts = '';
                this.totalAccounts = [result];
                this.visibleAccounts = [result];
            })
        }
    };
    get recordId(){
        return this._recordId;
    }
    
    searchValueChange(event){
        this.searchValue = event.target.value;
    }
    updateVisibleAccounts(event){
        console.log('Update VisibleRecords');
        console.log(event.detail.records);
        this.visibleAccounts=[...event.detail.records];
    }
    handleEnter(event){
        if(event.keyCode === 13){
            console.log('handleenter is activated');
            this.searchForAccounts();
        }
    }
    searchForAccounts(){
        if(!isNaN(this.searchValue) && this.searchValue.length>0){
            console.log('Search by sum is activated');
            SearchBySumOfOpportunities({searchString: this.searchValue})
            .then(result=>{
                console.log('Result by Sum is get');
                console.log(result);
                if(result!=null){
                    this.totalAccounts = result;
                }
                else{
                    this.sendErrorMessage('Nothing was found');
                }
            }).catch(error=>{
                console.log(error.message);
            });
        }
        else if(this.searchValue.length>0){
            console.log('Search by name is activated');
            SearchByNameOfAccount({searchString: this.searchValue})
            .then(result=>{
                console.log('Result by Name is get');
                console.log(result);
                if(result!=null){
                    this.totalAccounts = result;
                    }
                else{
                    this.sendErrorMessage('Nothing was found');
                }
            }).catch(error=>{
                console.log(error.message);
            });
        }
        else{
            console.log('Search by default is activated');
            getAccountInfoList().then(result=>{
                console.log('Result by default is get');
                this.totalAccounts = result;
            })
        }
    }
    sendErrorMessage(result){
        var eventMessage = new ShowToastEvent({
            title:'Oops',
            variant: 'error',
            message:result
        });
        this.dispatchEvent(eventMessage);
    }
}