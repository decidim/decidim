# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/component_context"

describe "Decidim::Api::QueryType" do
  include_context "with a graphql decidim component"
  let(:component_type) { "Elections" }
  let!(:current_component) { create :elections_component, participatory_space: participatory_process }
  let!(:election) { create(:election, :complete, :published, :finished, component: current_component) }

  let(:election_single_result) do
    {
      "attachments" => [],
      "bb_status" => election.bb_status,
      "blocked" => election.blocked?,
      "createdAt" => election.created_at.iso8601.to_s.gsub("Z", "+00:00"),
      "description" => { "translation" => election.description[locale] },
      "endTime" => election.end_time.iso8601.to_s.gsub("Z", "+00:00"),
      "id" => election.id.to_s,
      "publishedAt" => election.published_at.iso8601.to_s.gsub("Z", "+00:00"),

      "questions" => election.questions.order(:id).map do |q|
        {
          "answers" => q.answers.order(:id).map do |a|
            {
              "attachments" => [],
              "description" => begin
                { "translation" => a.description[locale] }
              rescue StandardError
                nil
              end,
              "id" => a.id.to_s,
              "proposals" => a.proposals.map { |p| { "id" => p.id.to_s } },
              "selected" => a.selected?,
              "title" => { "translation" => a.title[locale] },
              "versions" => [],
              "versionsCount" => 0,
              "results_total" => a.results_total.to_i,
              "weight" => a.weight.to_i
            }
          end,
          "id" => q.id.to_s,
          "maxSelections" => q.max_selections,
          "minSelections" => q.min_selections,
          "randomAnswersOrder" => q.random_answers_order,
          "title" => { "translation" => q.title[locale] },
          "versions" => [],
          "versionsCount" => 0,
          "weight" => q.weight
        }
      end,
      "startTime" => election.start_time.iso8601.to_s.gsub("Z", "+00:00"),
      "title" => { "translation" => election.title[locale] },
      "trustees" => [],
      "updatedAt" => election.updated_at.iso8601.to_s.gsub("Z", "+00:00"),
      "versions" => [],
      "versionsCount" => 0
    }
  end

  let(:elections_data) do
    {
      "__typename" => "Elections",
      "id" => current_component.id.to_s,
      "name" => { "translation" => "Elections" },
      "elections" => {
        "edges" => [
          {
            "node" => election_single_result
          }
        ]
      },
      "weight" => 0
    }
  end

  describe "valid connection query" do
    let(:component_fragment) do
      %(
        fragment fooComponent on Elections {
          elections{
            edges{
              node{
                attachments {
                  thumbnail
                }
                bb_status
                blocked
                createdAt
                description {
                  translation(locale: "en")
                }
                endTime
                id
                publishedAt
                questions {
                  answers {
                    attachments {  type}
                    description {
                      translation(locale: "en")
                    }
                    id
                    proposals {id }
                    selected
                    title {
                      translation(locale: "en")
                    }
                    versions {
                      id
                    }
                    versionsCount
                    results_total
                    weight
                  }
                  id
                  maxSelections
                  minSelections
                  randomAnswersOrder
                  title {
                    translation(locale: "en")
                  }
                  versions {
                    id
                  }
                  versionsCount
                  weight
                }
                startTime
                title {
                  translation(locale: "en")
                }
                trustees {
                  id
                }
                updatedAt
                versions {
                  id
                }
                versionsCount
              }
            }
          }
        }
      )
    end

    it "executes sucessfully" do
      expect { response }.not_to raise_error
    end

    it do
      expect(response["participatoryProcess"]["components"].first).to eq(elections_data)
    end
  end

  describe "valid query" do
    let(:component_fragment) do
      %(
      fragment fooComponent on Elections {
        election(id: #{election.id}){
          attachments {
            thumbnail
          }
          bb_status
          blocked
          createdAt
          description {
            translation(locale: "en")
          }
          endTime
          id
          publishedAt
          questions {
            answers {
              attachments {  type}
              description {
                translation(locale: "en")
              }
              id
              proposals {id }
              selected
              title {
                translation(locale: "en")
              }
              versions {
                id
              }
              versionsCount
              results_total
              weight
            }
            id
            maxSelections
            minSelections
            randomAnswersOrder
            title {
              translation(locale: "en")
            }
            versions {
              id
            }
            versionsCount
            weight
          }
          startTime
          title {
            translation(locale: "en")
          }
          trustees {
            id
          }
          updatedAt
          versions {
            id
          }
          versionsCount
        }
      }
)
    end

    it "executes sucessfully" do
      expect { response }.not_to raise_error
    end

    it do
      expect(response["participatoryProcess"]["components"].first["election"]).to eq(election_single_result)
    end
  end
end
