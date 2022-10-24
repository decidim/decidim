# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/component_context"
require "decidim/budgets/test/factories"

describe "Decidim::Api::QueryType" do
  include_context "with a graphql decidim component"
  let(:component_type) { "Budgets" }
  let!(:current_component) { create :budgets_component, participatory_space: participatory_process }
  let!(:budget) { create(:budget, component: current_component) }
  let!(:projects) { create_list(:project, 2, budget:, category:) }

  let(:budget_single_result) do
    {
      "createdAt" => budget.created_at.iso8601.to_s.gsub("Z", "+00:00"),
      "description" => { "translation" => budget.description[locale] },
      "id" => budget.id.to_s,
      "projects" => budget.projects.map do |project|
        {
          "acceptsNewComments" => project.accepts_new_comments?,
          "attachments" => [],
          "budget_amount" => project.budget_amount,
          "category" => { "id" => project.category.id.to_s },
          "comments" => [],
          "commentsHaveAlignment" => project.comments_have_alignment?,
          "commentsHaveVotes" => project.comments_have_votes?,
          "createdAt" => project.created_at.iso8601.to_s.gsub("Z", "+00:00"),
          "description" => { "translation" => project.description[locale] },
          "hasComments" => project.comment_threads.size.positive?,
          "id" => project.id.to_s,
          "reference" => project.reference,
          "scope" => nil,
          "selected" => project.selected?,
          "title" => { "translation" => project.title[locale] },
          "totalCommentsCount" => project.comments_count,
          "type" => "Decidim::Budgets::Project",
          "updatedAt" => project.updated_at.iso8601.to_s.gsub("Z", "+00:00"),
          "userAllowedToComment" => project.user_allowed_to_comment?(current_user)
        }
      end,
      "scope" => nil,
      "title" => { "translation" => budget.title[locale] },
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

  describe "valid connection query" do
    let(:budget_single_result) do
      {
        "createdAt" => budget.created_at.iso8601.to_s.gsub("Z", "+00:00"),
        "description" => { "translation" => budget.description[locale] },
        "id" => budget.id.to_s,
        "projects" => budget.projects.map { |project| { "id" => project.id.to_s } },
        "scope" => nil,
        "title" => { "translation" => budget.title[locale] },
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
      expect { response }.not_to raise_error
    end

    it do
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
      expect { response }.not_to raise_error
    end

    it do
      expect(response["participatoryProcess"]["components"].first["budget"]).to eq(budget_single_result)
    end
  end
end
