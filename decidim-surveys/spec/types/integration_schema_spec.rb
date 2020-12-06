# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/component_context"
require "decidim/budgets/test/factories"

describe "Decidim::Api::QueryType" do
  include_context "with a graphql decidim component"

  let(:participatory_process) { create :participatory_process, organization: current_organization }
  let!(:current_component) { create :surveys_component, participatory_space: participatory_process }
  let!(:survey) { create(:survey, component: current_component) }
  let!(:questionnaire) { create(:questionnaire, :with_questions, questionnaire_for: survey)}

  let(:survey_single_result) do
    {
      "createdAt" => survey.created_at.iso8601.to_s.gsub("Z", "+00:00"),
      "id" => survey.id.to_s,
      "questionnaire" => {
        "createdAt"=> survey.questionnaire.created_at.iso8601.to_s.gsub("Z", "+00:00"),
        "description"=>{"translation"=>survey.questionnaire.description[locale]},
        "forType"=>"Decidim::Surveys::Survey",
        "id"=>survey.questionnaire.id.to_s,
        "questions"=> survey.questionnaire.questions.map { |q| { "id" => q.id.to_s } } ,
        "title"=>{"translation"=>survey.questionnaire.title[locale]},
        "tos"=>{"translation"=>survey.questionnaire.tos[locale]},
        "updatedAt"=>survey.questionnaire.updated_at.iso8601.to_s.gsub("Z", "+00:00"),
      },
      "updatedAt" => survey.updated_at.iso8601.to_s.gsub("Z", "+00:00"),
    }
  end

  let(:survey_data) do
    {
      "__typename" => "Surveys",
      "id" => current_component.id.to_s,
      "name" => { "translation" => "Survey" },
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
                  id
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
        }
      }
)
    end

    it "executes sucessfully" do
      expect { response }.not_to raise_error(StandardError)
    end

    it "" do
      expect(response["participatoryProcess"]["components"].first).to eq(survey_data)
    end
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
              id
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

    it "executes sucessfully" do
      expect { response }.not_to raise_error(StandardError)
    end

    it "" do
      expect(response["participatoryProcess"]["components"].first["survey"]).to eq(survey_single_result)
    end
  end
end
