//Unit Tests

import { createElement } from 'lwc';
import SurveyFeedback from 'c/surveyFeedback';
import { registerApexTestWireAdapter } from '@salesforce/sfdx-lwc-jest';
import getSurveyQuestions from '@salesforce/apex/SurveyController.getSurveyQuestions';
import saveSurveyResponse from '@salesforce/apex/SurveyController.saveSurveyResponse';

const getSurveyQuestionsAdapter = registerApexTestWireAdapter(getSurveyQuestions);
const saveSurveyResponseAdapter = registerApexTestWireAdapter(saveSurveyResponse);

describe('Survey Feedback LWC', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('should get survey questions when recordId is provided', () => {
        const element = createElement('c-survey-feedback', {
            is: SurveyFeedback
        });
        element.recordId = '123';
        document.body.appendChild(element);

        return Promise.resolve().then(() => {
            const questions = [
                {
                    questionId: '1',
                    title: 'Question 1',
                    answerOptions: [
                        {
                            answerId: '1',
                            title: 'Answer 1'
                        },
                        {
                            answerId: '2',
                            title: 'Answer 2'
                        }
                    ]
                },
                {
                    questionId: '2',
                    title: 'Question 2',
                    answerOptions: [
                        {
                            answerId: '3',
                            title: 'Answer 3'
                        },
                        {
                            answerId: '4',
                            title: 'Answer 4'
                        }
                    ]
                }
            ];
            getSurveyQuestionsAdapter.emit(questions);
            const questionsEl = element.shadowRoot.querySelector('c-questions');
            expect(questionsEl.questions).toStrictEqual(questions);
        });
    });

    it('should show error message when no questions are found', () => {
        const element = createElement('c-survey-feedback', {
            is: SurveyFeedback
        });
        element.recordId = '123';
        document.body.appendChild(element);

        return Promise.resolve().then(() => {
            getSurveyQuestionsAdapter.emit(undefined);
            const errorEl = element.shadowRoot.querySelector('p');
            expect(errorEl.textContent).toBe('No questions found');
        });
    });

    it('should save survey response', () => {
        const element = createElement('c-survey-feedback', {
            is: SurveyFeedback
        });
        document.body.appendChild(element);
        const surveyResponse = {
            '1': '1',
            '2': '3'
        };
        element.surveyResponse = surveyResponse;

        return Promise.resolve().then(() => {
            saveSurveyResponseAdapter.emit('123');
            const savedResponse = element.shadowRoot.querySelector('p');
            expect(savedResponse.textContent).toBe('Survey response successfully saved');
        });
    });

    it('should show error message when survey response is not saved', () => {
        const element = createElement('c-survey-feedback', {
            is: SurveyFeedback
        });
        document.body.appendChild(element);
        const surveyResponse = {
            '1': '1',
            '2': '3'
        };
        element.surveyResponse = surveyResponse;

        return Promise.resolve().then(() => {
            saveSurveyResponseAdapter.emit(undefined);
            const errorEl = element.shadowRoot.querySelector('p');
            expect(errorEl.textContent).toBe('Failed to save survey response');
        });
    });
});