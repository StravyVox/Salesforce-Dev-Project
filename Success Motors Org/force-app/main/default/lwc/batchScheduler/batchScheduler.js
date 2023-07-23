import { LightningElement, api } from 'lwc';
import trySetBatch from '@salesforce/apex/BatchSchedulerLWCController.trySetBatch';
import runJobOnce from '@salesforce/apex/BatchSchedulerLWCController.runJobOnce';
import isJobAlreadyQueued from '@salesforce/apex/BatchSchedulerLWCController.isJobAlreadyQueued';
import scheduleJob from '@salesforce/apex/BatchSchedulerLWCController.scheduleJob';
import abortJob from '@salesforce/apex/BatchSchedulerLWCController.abortJob';
import TitleLabel from '@salesforce/label/c.Batch_Title'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class BatchScheduler extends LightningElement {
    @api BatchClassName;
    @api BatchNameSet;
    @api JobName;
    @api CRONExp;
    @api disabledInput = false;
    BatchSet = false;
    JobSet = false;
    label = TitleLabel;
    changeBatchValue(event){
        this.BatchClassName = event.target.value;
    }
    changeJobValue(event){
        this.JobName = event.target.value;
    }
    changeCRONValue(event){
        this.CRONExp = event.target.value;
    }
    addBatchName(){
        trySetBatch({BatchName: this.BatchClassName})
        .then(result=>{
            if(result==true){
                this.BatchSet = true;
                this.checkIfJobAlreadySet();
            }
            else{
                this.sendMessage(3);
            }
        })
    }
    connectedCallback(){
        this.addBatchName();
    }
    checkIfJobAlreadySet(){
        isJobAlreadyQueued({jobName: this.JobName})
        .then(result=>{
            if(result){
                this.JobSet = true;
                this.disabledInput = true;
            }
            else{
                this.JobSet = false;
                this.disabledInput = false;
            }
        });
    }
    runOnce(){
        runJobOnce({batchName: this.BatchClassName, jobName: this.JobName})
        .then(result=>{
            if(result){
                this.sendMessage(1);
            }
            else{
                this.sendMessage(-1);
            }
        });
    }
    abortJob(){
        abortJob({jobName:this.JobName})
        .then(result=>{
            if(result){
                this.sendMessage(2);
                this.JobSet = false;
                this.disabledInput = false;
            }
            else{
                this.sendMessage(-1);
            }
        })
    }
    scheduleJob(){
        scheduleJob({batchName: this.BatchClassName, jobName: this.JobName, cronExp: this.CRONExp})
        .then(result=>{
            if(result){
                this.sendMessage(1);
                
                this.checkIfJobAlreadySet();
            }
            else{
                this.sendMessage(4);
            }
        });
    }
    sendMessage(result){
        switch(result){
            case 1:
                var eventMessage = new ShowToastEvent({
                    title:'Success',
                    variant: 'success',
                    message:'Successfully scheduled'
                });
                this.dispatchEvent(eventMessage);
                break;
            case 2:
                var eventMessage = new ShowToastEvent({
                    title:'Success',
                    variant: 'success',
                    message:'Successfully aborted'
                });
                this.dispatchEvent(eventMessage);
                break;
            case 3:
                var eventMessage = new ShowToastEvent({
                    title:'Error',
                    variant: 'error',
                    message:'Batch name is incorrect'
                });
                this.dispatchEvent(eventMessage);
                break;
            case 4:
                var eventMessage = new ShowToastEvent({
                    title:'Error',
                    variant: 'error',
                    message:'CRON Expression is incorrect'
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