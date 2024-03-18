# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/component_context"
require "decidim/budgets/test/factories"

describe "Decidim::Api::QueryType" do
  include_context "with a graphql decidim component"

  let(:component_type) { "Surveys" }
  let!(:current_component) { create(:surveys_component, participatory_space: participatory_process) }
  let!(:survey) { create(:survey, component: current_component) }
  let!(:questionnaire) { create(:questionnaire, :with_questions, questionnaire_for: survey) }

  let(:survey_single_result) do
    survey.reload
    {
      "createdAt" => survey.created_at.iso8601.to_s.gsub("Z", "+00:00"),
      "id" => survey.id.to_s,
      "questionnaire" => {
        "createdAt" => survey.questionnaire.created_at.iso8601.to_s.gsub("Z", "+00:00"),
        "description" => { "translation" => survey.questionnaire.description[locale] },
        "forType" => "Decidim::Surveys::Survey",
        "id" => survey.questionnaire.id.to_s,
        "questions" => survey.questionnaire.questions.map do |q|
          {
            "answerOptions" => q.answer_options.map do |a|
              {
                "body" => { "translation" => a.body[locale] },
                "freeText" => a.free_text?,
                "id" => a.id.to_s
              }
            end,
            "body" => { "translation" => q.body[locale] },
            "createdAt" => q.created_at.iso8601.to_s.gsub("Z", "+00:00"),
            "description" => { "translation" => q.description[locale] },
            "id" => q.id.to_s,
            "mandatory" => q.mandatory?,
            "maxChoices" => q.max_choices,
            "position" => q.position,
            "questionType" => q.question_type,
            "updatedAt" => q.updated_at.iso8601.to_s.gsub("Z", "+00:00")
          }
        end,
        "title" => { "translation" => survey.questionnaire.title[locale] },
        "tos" => { "translation" => survey.questionnaire.tos[locale] },
        "updatedAt" => survey.questionnaire.updated_at.iso8601.to_s.gsub("Z", "+00:00")
      },
      "updatedAt" => survey.updated_at.iso8601.to_s.gsub("Z", "+00:00")
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
                  answerOptions {
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
            # forEntity {
            #   id
            #   __typename
            # }
            forType
            id
            questions {
              answerOptions {
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

    it "executes successfully" do
      expect { response }.not_to raise_error
    end

    it { expect(response["participatoryProcess"]["components"].first["survey"]).to eq(survey_single_result) }
  end
end
