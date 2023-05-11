import { LightningElement, api, track } from 'lwc';

import getSurveyQuestions from '@salesforce/apex/SurveyController.getSurveyQuestions';
import saveSurveyResponse from '@salesforce/apex/SurveyController.saveSurveyResponse';

export default class SurveyFeedback extends LightningElement {
    @api recordId;
    @track questions;
    @track surveyResponse;
    @track error;

    connectedCallback() {
        if (this.recordId) {
            getSurveyQuestions({ surveyId: this.recordId })
                .then(result => {
                    this.error = undefined;
                    if (result) {
                        this.questions = result;
                    } else {
                        this.error = 'No questions found';
                    }
                })
                .catch(error => {
                    this.error = error;
                    this.questions = undefined;
                });
        }
    }

    handleAnswerChange(event) {
        const questionId = event.target.name;
        const answer = event.detail.value;
        if (!this.surveyResponse) {
            this.surveyResponse = {};
        }
        this.surveyResponse[questionId] = answer;
    }

    handleSave() {
        saveSurveyResponse({ surveyResponse: JSON.stringify(this.surveyResponse) })
            .then(result => {
                this.error = undefined;
                if (result) {
                    // TODO: Show success message
                } else {
                    this.error = 'Failed to save survey response';
                }
            })
            .catch(error => {
                this.error = error;
            });
    }
}