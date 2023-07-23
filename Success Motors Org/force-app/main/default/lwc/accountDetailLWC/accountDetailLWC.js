import { LightningElement, wire,track,api } from 'lwc';
import getAccountInfoList from '@salesforce/apex/AccountDetailController.getAccountInfoList'
import getAccount from '@salesforce/apex/AccountDetailController.getAccount';
import searchByNameOfAccount from '@salesforce/apex/AccountDetailController.searchByNameOfAccount';
import searchBySumOfOpportunities from '@salesforce/apex/AccountDetailController.searchBySumOfOpportunities';
import TitleLabel from '@salesforce/label/c.AccountDetail_Title'
export default class AccountDetailLWC extends LightningElement {
    label = TitleLabel;
    visibleAccounts;
    totalAccounts;
    _recordId;
    @track searchValue;
    @wire(getAccountInfoList) function ({data,error}) {
        if(data){
            this.totalAccounts =  data;
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
        this.searchForAccounts();
    }
    updateVisibleAccounts(event){
        this.visibleAccounts=[...event.detail.records];
    }
    handleEnter(event){
        if(event.keyCode === 13){
            this.searchForAccounts();
        }
    }
    searchForAccounts(){
        if(!isNaN(this.searchValue) && this.searchValue.length>0){
            searchBySumOfOpportunities({searchString: this.searchValue})
            .then(result=>{
                if(result!=null && result.length > 0){
                    this.totalAccounts = result;
                }
                else{
                    this.totalAccounts = [];
                }
            })
            .catch(error=>{});
        }
        else if(this.searchValue.length>0){
            searchByNameOfAccount({searchString: this.searchValue})
            .then(result=>{
                if(result!=null && result.length > 0){
                    this.totalAccounts = result;
                }
                else{
                    this.totalAccounts = [];
                }
            })
            .catch(error=>{});
        }
        else{
            getAccountInfoList().then(result=>{
                this.totalAccounts = result;
            })
        }
    }
}