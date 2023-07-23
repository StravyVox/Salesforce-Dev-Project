import { LightningElement, api, track} from 'lwc';

export default class DatatablePaginator extends LightningElement {
    @api set mainData(value){
        if(value){
            var length = value.length;
            this.data = value;
            console.log(this.data);
            this.totalPage = Math.ceil(length / this.sizeOfPage);
            this.updateRecords();
        }
    }
    get mainData(){
        return this.data;
    }
    @api sizeOfPage = 3;
    @track visibleData;
    currentPage = 1;
    totalPage = 1;
 
    get disablePrevious(){ 
        return this.currentPage<=1;
    }
    get disableNext(){ 
        return this.currentPage>=this.totalPage;
    }
    nextHandler(){
        this.currentPage += 1;
        this.updateRecords();
    }
    backHandler(){
        this.currentPage -=1;
        this.updateRecords()
    }
    updateRecords(){
        const start = (this.currentPage-1)*this.sizeOfPage;
        const end = this.sizeOfPage*this.currentPage;
        this.visibleData = this.mainData.slice(start,end);
        var updateEvent = new CustomEvent('page',{detail: this.visibleData});
        this.dispatchEvent(updateEvent);
    }
}