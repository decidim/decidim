# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/component_context"
require "decidim/budgets/test/factories"

describe "Decidim::Api::QueryType" do
  include_context "with a graphql decidim component"
  let(:component_type) { "Sortitions" }
  let!(:current_component) { create :sortition_component, participatory_space: participatory_process }
  let!(:sortition) { create(:sortition, component: current_component, category:) }

  let(:sortition_single_result) do
    sortition.reload
    {
      "acceptsNewComments" => sortition.accepts_new_comments?,
      "additionalInfo" => { "translation" => sortition.additional_info[locale] },
      "author" => { "id" => sortition.normalized_author.id.to_s },
      "cancelReason" => sortition.cancel_reason,
      "cancelledByUser" => sortition.cancelled_by_user,
      "cancelledOn" => sortition.cancelled_on,
      "candidateProposals" => sortition.candidate_proposals,
      "category" => { "id" => sortition.category.id.to_s },
      "comments" => [],
      "commentsHaveAlignment" => sortition.comments_have_alignment?,
      "commentsHaveVotes" => sortition.comments_have_votes?,
      "createdAt" => sortition.created_at.iso8601.to_s.gsub("Z", "+00:00"),
      "dice" => sortition.dice,
      "hasComments" => sortition.comment_threads.size.positive?,
      "id" => sortition.id.to_s,
      "reference" => sortition.reference,
      "requestTimestamp" => sortition.request_timestamp.to_date.to_s,
      "selectedProposals" => sortition.selected_proposals,
      "targetItems" => sortition.target_items,
      "title" => { "translation" => sortition.title[locale] },
      "totalCommentsCount" => sortition.comments_count,
      "type" => "Decidim::Sortitions::Sortition",
      "updatedAt" => sortition.updated_at.iso8601.to_s.gsub("Z", "+00:00"),
      "userAllowedToComment" => sortition.user_allowed_to_comment?(current_user),
      "witnesses" => { "translation" => sortition.witnesses[locale] }
    }
  end

  let(:sortition_data) do
    {
      "__typename" => "Sortitions",
      "id" => current_component.id.to_s,
      "name" => { "translation" => "Sortitions" },
      "sortitions" => {
        "edges" => [
          {
            "node" => sortition_single_result
          }
        ]
      },
      "weight" => 0
    }
  end

  describe "valid connection query" do
    let(:component_fragment) do
      %(
        fragment fooComponent on Sortitions {
          sortitions {
            edges{
              node{
                acceptsNewComments
                additionalInfo {  translation(locale: "#{locale}") }
                author { id }
                cancelReason { translation(locale: "#{locale}") }
                cancelledByUser { id }
                cancelledOn
                candidateProposals
                category { id }
                comments { id }
                commentsHaveAlignment
                commentsHaveVotes
                createdAt
                dice
                hasComments
                id
                reference
                requestTimestamp
                selectedProposals
                targetItems
                title { translation(locale: "#{locale}") }
                totalCommentsCount
                type
                updatedAt
                userAllowedToComment
                witnesses { translation(locale: "#{locale}") }
              }
            }
          }
        }
      )
    end

    it "executes sucessfully" do
      expect { response }.not_to raise_error
    end

    it { expect(response["participatoryProcess"]["components"].first).to eq(sortition_data) }
  end

  describe "valid query" do
    let(:component_fragment) do
      %(
      fragment fooComponent on Sortitions {
        sortition(id: #{sortition.id}){
          acceptsNewComments
          additionalInfo {  translation(locale: "#{locale}") }
          author { id }
          cancelReason { translation(locale: "#{locale}") }
          cancelledByUser { id }
          cancelledOn
          candidateProposals
          category { id }
          comments { id }
          commentsHaveAlignment
          commentsHaveVotes
          createdAt
          dice
          hasComments
          id
          reference
          requestTimestamp
          selectedProposals
          targetItems
          title { translation(locale: "#{locale}") }
          totalCommentsCount
          type
          updatedAt
          userAllowedToComment
          witnesses { translation(locale: "#{locale}") }
        }
      }
    )
    end

    it "executes sucessfully" do
      expect { response }.not_to raise_error
    end

    it { expect(response["participatoryProcess"]["components"].first["sortition"]).to eq(sortition_single_result) }
  end
end
