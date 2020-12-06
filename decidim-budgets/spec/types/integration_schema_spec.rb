# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/component_context"
require "decidim/budgets/test/factories"

describe "Decidim::Api::QueryType" do
  include_context "with a graphql decidim component"

  let(:budget_single_result) do
    first_project = budget.projects.first
    last_project = budget.projects.last
    {
      "createdAt" => budget.created_at.iso8601.to_s.gsub("Z", "+00:00"),
      "description" => {"translation" => budget.description[locale]},
      "id" => budget.id.to_s,
      "projects" => [{
                       "acceptsNewComments" => first_project.accepts_new_comments?,
                       "attachments"=>[],
                       "budget_amount"=>first_project.budget_amount,
                       "category"=>{"id"=>first_project.category.id.to_s},
                       "comments"=>[],
                       "commentsHaveAlignment"=>first_project.comments_have_alignment?,
                       "commentsHaveVotes"=>first_project.comments_have_votes?,
                       "createdAt"=>first_project.created_at.iso8601.to_s.gsub("Z", "+00:00"),
                       "description"=>{"translation"=>first_project.description[locale]},
                       "hasComments"=>first_project.comment_threads.size.positive?,
                       "id"=>first_project.id.to_s,
                       "reference"=> first_project.reference,
                       "scope"=>nil,
                       "selected"=>first_project.selected?,
                       "title"=>{"translation"=>first_project.title[locale]},
                       "totalCommentsCount"=>first_project.comments_count,
                       "type"=>"Decidim::Budgets::Project",
                       "updatedAt"=>first_project.updated_at.iso8601.to_s.gsub("Z", "+00:00"),
                       "userAllowedToComment"=>first_project.user_allowed_to_comment?(current_user)
                      }, {
                        "acceptsNewComments" => last_project.accepts_new_comments?,
                        "attachments"=>[],
                        "budget_amount"=>last_project.budget_amount,
                        "category"=>{"id"=>last_project.category.id.to_s},
                        "comments"=>[],
                        "commentsHaveAlignment"=>last_project.comments_have_alignment?,
                        "commentsHaveVotes"=>last_project.comments_have_votes?,
                        "createdAt"=>last_project.created_at.iso8601.to_s.gsub("Z", "+00:00"),
                        "description"=>{"translation"=>last_project.description[locale]},
                        "hasComments"=>last_project.comment_threads.size.positive?,
                        "id"=>last_project.id.to_s,
                        "reference"=> last_project.reference,
                        "scope"=>nil,
                        "selected"=>last_project.selected?,
                        "title"=>{"translation"=>last_project.title[locale]},
                        "totalCommentsCount"=>last_project.comments_count,
                        "type"=>"Decidim::Budgets::Project",
                        "updatedAt"=>last_project.updated_at.iso8601.to_s.gsub("Z", "+00:00"),
                        "userAllowedToComment"=>last_project.user_allowed_to_comment?(current_user)
                      }],
      "scope" => nil,
      "title" => {"translation"=>budget.title[locale]},
      "total_budget" => budget.total_budget,
      "updatedAt" => budget.updated_at.iso8601.to_s.gsub("Z", "+00:00"),
      "versions" => [],
      "versionsCount" => 0
    }
  end

  let(:budgets_data) do
    {
      "__typename" => "Budgets",
      "id" => current_component.id.to_s,
      "name" => { "translation" => "Budgets" },
      "budgets" => {
        "edges" => [
          {
            "node" => budget_single_result
          }
        ]
      },
      "weight" => 0
    }
  end

  let(:participatory_process) { create :participatory_process, organization: current_organization }
  let!(:current_component) { create :budgets_component, participatory_space: participatory_process }
  let!(:budget) { create(:budget, :with_projects, component: current_component) }

  describe "valid connection query" do
    let(:budget_single_result) do
      first_project = budget.projects.first
      last_project = budget.projects.last
      {
        "createdAt" => budget.created_at.iso8601.to_s.gsub("Z", "+00:00"),
        "description" => {"translation" => budget.description[locale]},
        "id" => budget.id.to_s,
        "projects" => [{
                         "id"=>first_project.id.to_s,
                       }, {
                         "id"=>last_project.id.to_s,
                       }],
        "scope" => nil,
        "title" => {"translation"=>budget.title[locale]},
        "total_budget" => budget.total_budget,
        "updatedAt" => budget.updated_at.iso8601.to_s.gsub("Z", "+00:00"),
        "versions" => [],
        "versionsCount" => 0
      }
    end

    let(:component_fragment) do
      %(
      fragment fooComponent on Budgets {
        budgets {
          edges{
            node{
              createdAt
              description {
                translation(locale:"#{locale}")
              }
              id
              projects {
                id
              }
              scope {
                id
                name{
                  translation(locale:"#{locale}")
                }
              }
              title {
                translation(locale:"#{locale}")
              }
              total_budget
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
      expect { response }.not_to raise_error(StandardError)
    end

    it "" do
      expect(response["participatoryProcess"]["components"].first).to eq(budgets_data)
    end
  end

  describe "valid query" do
    let(:component_fragment) do
      %(
      fragment fooComponent on Budgets {
        budget(id: #{budget.id}) {
          createdAt
          description {
            translation(locale:"#{locale}")
          }
          id
          projects {
            acceptsNewComments
            attachments{
              type
            }
            budget_amount
            category{ id }
            comments{ id }
            commentsHaveAlignment
            commentsHaveVotes
            createdAt
            description{ translation(locale: "#{locale}")}
            hasComments
            id
            reference
            scope{ id }
            selected
            title{ translation(locale: "#{locale}")}
            totalCommentsCount
            type
            updatedAt
            userAllowedToComment
          }
          scope {
            id
            name{
              translation(locale:"#{locale}")
            }
          }
          title {
            translation(locale:"#{locale}")
          }
          total_budget
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
      expect { response }.not_to raise_error(StandardError)
    end

    it "" do
      expect(response["participatoryProcess"]["components"].first["budget"]).to eq(budget_single_result)
    end
  end
end
