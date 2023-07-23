import { LightningElement, track, wire, api } from 'lwc';
import ReturnCases from '@salesforce/apex/DatatableController.ReturnCases';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import Status from '@salesforce/schema/Case.Status';
import Type from '@salesforce/schema/Case.Type';
import CASES_OBJECT from '@salesforce/schema/Case';
import {exportCSVFile} from './csvController';

const columns = [
    { label: 'Case Number', fieldName: 'CaseNumber',sortable: true,hideDefaultActions: "true" },
    { label: 'Product', fieldName: 'Product__c',sortable: true,hideDefaultActions: "true"},
    { label: 'Status', fieldName: 'Status',sortable: true,hideDefaultActions: "true",
    actions: [
        { label: 'all', checked: true, name: 'all' }] },
    { label: 'Created Date', fieldName: 'CreatedDate',type:'date', sortable:true,hideDefaultActions: "true"},
    { label: 'Type',fieldName:'Type', sortable:true,hideDefaultActions: "true",
    actions: [
        { label: 'all', checked: true, name: 'all' },]}
];

export default class CasesDatatable extends LightningElement {
    sortedBy;
    sortDirection;
    defaultSortDirection = 'asc';
    fulldata;
    picklistValues;
    @api pageSize;
    @track columns = columns; 
    @track data;
    @track displayedData;
    @wire (getObjectInfo, {objectApiName: CASES_OBJECT}) objectInfo;
    @wire (getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: Status}) 
    statusPicklistValues({ error, data }) {
        this.picklistValues = undefined;
        var buffColumns = this.columns;
        if (data) {
            this.picklistValues = data;
            this.picklistValues.values.forEach(picklistEntry => {
                buffColumns.find(obj=>obj.label==='Status').actions.push({label: picklistEntry.label, checked: false, name: picklistEntry.label});
            });
            this.columns = [...buffColumns];
        } else if (error) {
            console.log(error);
        }
    }  
    @wire (getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: Type}) 
    typePicklistValues({ error, data }) {
        this.picklistValues = undefined;
        var buffColumns = this.columns;
        if (data) {
            this.picklistValues = data;
            this.picklistValues.values.forEach(picklistEntry => {
                buffColumns.find(obj=>obj.label==='Type').actions.push({label: picklistEntry.label, checked: false, name: picklistEntry.label});
            });
            this.columns = [...buffColumns]
        } else if (error) {
            console.log(error);
        }
    }  
    
    @wire (ReturnCases, {}) returnedData(result){ 
       if(result.data){
            this.data = result.data;
            this.fulldata = result.data;
            this.displayedData = result.data;
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