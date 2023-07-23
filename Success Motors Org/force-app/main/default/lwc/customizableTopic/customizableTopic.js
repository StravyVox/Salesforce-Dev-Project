import { LightningElement,api } from 'lwc';

export default class CustomizableTopic extends LightningElement {
    @api topic;
    @api header;
    @api headerCssClass;
    @api topicCssClass;
}