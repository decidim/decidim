# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"
require "decidim/surveys/test/factories"

describe "Decidim::Api::QueryType" do
  include_context "with a graphql decidim component" do
    let(:component_fragment) do
      %(
      fragment fooComponent on Surveys {
        survey(id: #{survey.id}){
          createdAt
          id
          questionnaire{
            createdAt
            description {
              translation(locale:"#{locale}")
            }
            forType
            id
            questions {
              responseOptions {
                id
                body { translation(locale:"#{locale}") }
                freeText
              }
              body { translation(locale:"#{locale}") }
              createdAt
              description { translation(locale:"#{locale}") }
              id
              mandatory
              maxChoices
              position
              questionType
              updatedAt
            }
            title {
              translation(locale:"#{locale}")
            }
            tos {
              translation(locale:"#{locale}")
            }
            updatedAt
          }
          updatedAt
        }
      }
)
    end
  end

  let(:component_type) { "Surveys" }
  let!(:current_component) { create(:surveys_component, participatory_space: participatory_process) }
  let!(:survey) { create(:survey, component: current_component) }
  let!(:questionnaire) { create(:questionnaire, :with_questions, questionnaire_for: survey) }

  let(:survey_single_result) do
    survey.reload
    {
      "createdAt" => survey.created_at.to_time.iso8601,
      "id" => survey.id.to_s,
      "questionnaire" => {
        "createdAt" => survey.questionnaire.created_at.to_time.iso8601,
        "description" => { "translation" => survey.questionnaire.description[locale] },
        "forType" => "Decidim::Surveys::Survey",
        "id" => survey.questionnaire.id.to_s,
        "questions" => survey.questionnaire.questions.map do |q|
          {
            "responseOptions" => q.response_options.map do |a|
              {
                "body" => { "translation" => a.body[locale] },
                "freeText" => a.free_text?,
                "id" => a.id.to_s
              }
            end,
            "body" => { "translation" => q.body[locale] },
            "createdAt" => q.created_at.to_time.iso8601,
            "description" => { "translation" => q.description[locale] },
            "id" => q.id.to_s,
            "mandatory" => q.mandatory?,
            "maxChoices" => q.max_choices,
            "position" => q.position,
            "questionType" => q.question_type,
            "updatedAt" => q.updated_at.to_time.iso8601
          }
        end,
        "title" => { "translation" => survey.questionnaire.title[locale] },
        "tos" => { "translation" => survey.questionnaire.tos[locale] },
        "updatedAt" => survey.questionnaire.updated_at.to_time.iso8601
      },
      "updatedAt" => survey.updated_at.to_time.iso8601
    }
  end

  let(:survey_data) do
    {
      "__typename" => "Surveys",
      "id" => current_component.id.to_s,
      "name" => { "translation" => translated(current_component.name) },
      "surveys" => {
        "edges" => [
          {
            "node" => survey_single_result
          }
        ]
      },
      "weight" => 0
    }
  end

  describe "valid connection query" do
    let(:component_fragment) do
      %(
      fragment fooComponent on Surveys {
        surveys{
          edges{
            node{
              createdAt
              id
              questionnaire{
                createdAt
                description {
                  translation(locale:"#{locale}")
                }
                # forEntity {
                #   id
                #   __typename
                # }
                forType
                id
                questions {
                  responseOptions {
                    id
                    body { translation(locale:"#{locale}") }
                    freeText
                  }
                  body { translation(locale:"#{locale}") }
                  createdAt
                  description { translation(locale:"#{locale}") }
                  id
                  mandatory
                  maxChoices
                  position
                  questionType
                  updatedAt
                }
                title { translation(locale:"#{locale}") }
                tos {
                  translation(locale:"#{locale}")
                }
                updatedAt
              }
              updatedAt
            }
          }
        }
      }
)
    end

    it "executes successfully" do
      expect { response }.not_to raise_error
    end

    it { expect(response["participatoryProcess"]["components"].first).to eq(survey_data) }
  end

  describe "valid query" do
    it "executes successfully" do
      expect { response }.not_to raise_error
    end

    it { expect(response["participatoryProcess"]["components"].first["survey"]).to eq(survey_single_result) }
  end

  context "with resource visibility" do
    include_examples "with resource visibility" do
      let(:component_factory) { :surveys_component }
      let(:lookout_key) { "survey" }
      let(:query_result) { survey_single_result }

      before do
        step_settings = {}
        if current_component.participatory_space.respond_to?(:active_step)
          step_settings = {
            current_component.participatory_space.active_step.id => {
              allow_responses: true,
              allow_unregistered: true
            }
          }
        end

        current_component.reload
        current_component.update!(
          step_settings:,
          settings: { starts_at: 1.week.ago, ends_at: 1.day.from_now }
        )
      end
    end
  end
end
