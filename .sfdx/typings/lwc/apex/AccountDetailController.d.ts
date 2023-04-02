declare module "@salesforce/apex/AccountDetailController.getAccountInfoList" {
  export default function getAccountInfoList(): Promise<any>;
}
declare module "@salesforce/apex/AccountDetailController.SearchByNameOfAccount" {
  export default function SearchByNameOfAccount(param: {searchString: any}): Promise<any>;
}
declare module "@salesforce/apex/AccountDetailController.SearchBySumOfOpportunities" {
  export default function SearchBySumOfOpportunities(param: {searchString: any}): Promise<any>;
}
declare module "@salesforce/apex/AccountDetailController.getAccount" {
  export default function getAccount(param: {Id: any}): Promise<any>;
}
declare module "@salesforce/apex/AccountDetailController.getOpportunityProduct" {
  export default function getOpportunityProduct(param: {OpportunityId: any}): Promise<any>;
}
