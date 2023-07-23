export function exportCSVFile(totalData, fileName){
    if(!totalData || !totalData.length){
        return null
    }
    
    var headers = Object.keys(totalData[0]);
    const result = convertToCSV(totalData, headers);
    if(result === null) return;

    let downloadElement = document.createElement('a');
    downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURIComponent(result);
    downloadElement.target = '_self';
    downloadElement.download = 'Data.csv';
    downloadElement.click(); 
}
function convertToCSV(objArray, headers){
    const columnDelimiter = ','
    const lineDelimiter = '\r\n'
    const actualHeaderKey = headers;
    const headerToShow = headers;
    let str = '';
    str+=headerToShow.join(columnDelimiter) ;
    str+=lineDelimiter;
    const data = objArray;

    data.forEach(obj=>{
        let line = ''
        actualHeaderKey.forEach(key=>{
            if(line !=''){
                line+=columnDelimiter;
            }
            let strItem = obj[key]+'';
            line+=strItem? strItem.replace(/,/g, ''):strItem;
        })
        str+=line+lineDelimiter;
    })
    return str;
}
