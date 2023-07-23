import { LightningElement, track, wire, api } from 'lwc';
import ReturnOpportunities from '@salesforce/apex/DatatableController.ReturnOpportunities';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import StageName from '@salesforce/schema/Opportunity.StageName';
import OPPORTUNITY_OBJECT from '@salesforce/schema/Opportunity';
import {exportCSVFile} from './csvController';

const columns = [
    { label: 'Opportunity Name', fieldName: 'Name',sortable: true,hideDefaultActions: "true" },
    { label: 'Stage', fieldName: 'StageName',sortable: true,hideDefaultActions: "true",
    actions: [
        { label: 'all', checked: true, name: 'all' }]},
    { label: 'Created date', fieldName: 'CreatedDate',sortable: true,type: 'date',hideDefaultActions: "true" },
    { label: 'Invoice number', fieldName: 'SMotors__Invoice_Number__c', sortable:true, type: 'string', hideDefaultActions: "true"},
    { label: 'Payment State',fieldName:'PaymentStatus', sortable:true,hideDefaultActions: "true",
    actions: [
        { label: 'all', checked: true, name: 'all' },
        { label: 'Fully Paid', checked: false, name: 'Fully Paid' },
        { label: 'Partially Paid', checked: false, name: 'Partially Paid' },
        { label: 'Not Paid', checked: false, name: 'Not Paid' }]}
];

export default class OpportunityDatatable extends LightningElement {
    sortedBy;
    sortDirection;
    defaultSortDirection = 'asc';
    fulldata;
    picklistValues;
    @api pageSize;
    @track columns = columns; 
    @track data;
    @track displayedData;
    @wire (getObjectInfo, {objectApiName: OPPORTUNITY_OBJECT}) objectInfo;
    @wire (getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: StageName}) 
    wiredPicklistValues({ error, data }) {
        this.picklistValues = undefined;
        var buffColumns = this.columns;
        if (data) {
            this.picklistValues = data;
            this.picklistValues.values.forEach(picklistEntry => {
                buffColumns[1].actions.push({label: picklistEntry.label, checked: false, name: picklistEntry.label});
            });
            var result = [...buffColumns];
            this.columns = result;
        }
    }  
    @wire (ReturnOpportunities, {}) returnedData(result){
        if(result.error){
            console.log(result.error);
        }
        else if(result.data){
            var info = [];
            result.data.forEach(opportunity => {
                let tempObject = Object.assign({}, opportunity)
                if(opportunity.StageName === 'Fully Paid'|| opportunity.StageName === 'Partially Paid'){
                    tempObject.PaymentStatus = opportunity.StageName;
                }
                else if(opportunity.StageName === 'Closed Won'){
                    tempObject.PaymentStatus = 'Fully Paid';
                }
                else{
                    tempObject.PaymentStatus = 'Not Paid';
                }
                info.push(tempObject);
            });
            this.data = info;
            this.fulldata = info;
            this.displayedData = info;
        }
    }

    updateDisplayedData(event){
        this.displayedData = event.detail;
    }
    sortData(fieldName, sortDir){
        this.sortDirection = sortDir;
        var sortingData = [...this.data];
        var reverse = sortDir === 'asc'?1:-1;
        sortingData.sort((a,b)=>{
            a = a[fieldName];
            b = b[fieldName];
            return reverse * ((a > b) - (b > a));
        });
        return sortingData;
    }
    updateColumnSorting(event) {
        var fieldName = event.detail.fieldName;
        var sortDirection = event.detail.sortDirection;
        this.data = this.sortData(fieldName, sortDirection);
        this.sortedBy = fieldName;
        this.sortedDirection = sortDirection;
   }

   handleHeaderAction(event) {
    const actionName = event.detail.action.name;
    const colDef = event.detail.columnDefinition;
    let cols = this.columns;

    if (actionName !== undefined && actionName !== 'all') {
        this.data = this.fulldata;
        this.data = this.data.filter(row =>row[colDef.fieldName] === actionName);
    } 
    else if (actionName === 'all') {
        this.data = this.fulldata;
    }
    cols.find(col => col.label === colDef.label).actions.forEach(action => action.checked = action.name === actionName);
    this.columns = [...cols];
    }

    downloadData(){
        exportCSVFile(this.data, "details.csv");
    }
}