# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/component_context"
require "decidim/budgets/test/factories"

describe "Decidim::Api::QueryType" do
  include_context "with a graphql decidim component"

    let(:participatory_process) { create :participatory_process, organization: current_organization }
    let!(:current_component) { create :elections_component, participatory_space: participatory_process }
    let!(:election) { create(:election, :complete, component: current_component) }

  let(:election_single_result) do
    {
#       "acceptsNewComments" => debate.accepts_new_comments?,
#       "author" => { "id"=>debate.author.id.to_s },
#       "category" => { "id"=>debate.category.id.to_s },
#       "comments"=>[],
#       "commentsHaveAlignment" => debate.comments_have_alignment?,
#       "commentsHaveVotes" => debate.comments_have_votes?,
#       "createdAt" => debate.created_at.iso8601.to_s.gsub("Z", "+00:00"),
#       "description" => {"translation" => debate.description[locale]},
#       "endTime"=>debate.end_time,
#       "hasComments" => debate.comment_threads.size.positive?,
#       "id" => debate.id.to_s,
#       "image" => nil,
#       "informationUpdates"=>{"translation"=>debate.information_updates[locale]},
#       "instructions"=>{"translation"=>debate.instructions[locale]},
#       "reference"=>debate.reference,
#       "startTime"=>debate.start_time,
#       "title"=>{"translation"=>debate.title[locale]},
#       "totalCommentsCount"=>debate.comments_count,
#       "type" => "Decidim::Debates::Debate",
#       "updatedAt" => debate.updated_at.iso8601.to_s.gsub("Z", "+00:00"),
#       "userAllowedToComment" => debate.user_allowed_to_comment?(current_user),
    }
  end

  let(:elections_data) do
    {
      "__typename" => "Debates",
      "id" => current_component.id.to_s,
      "name" => { "translation" => "Debates" },
      "debates" => {
        "edges" => [
          {
            "node" => election_single_result
          }
        ]
      },
      "weight" => 0
    }
  end
#
  describe "valid connection query" do

    let(:component_fragment) do
      %(
      fragment fooComponent on Elections {
        elections{
          edges{
            node{
#               acceptsNewComments
#               author {
#                 id
#               }
#               category {
#                 id
#               }
#               comments {
#                 id
#               }
#               commentsHaveAlignment
#               commentsHaveVotes
#               createdAt
#               description {
#                 translation(locale: "#{locale}")
#               }
#               endTime
#               hasComments
#               id
#               image
#               informationUpdates {
#                 translation(locale: "#{locale}")
#               }
#               instructions {
#                 translation(locale: "#{locale}")
#               }
#               reference
#               startTime
#               title {
#                 translation(locale: "#{locale}")
#               }
#               totalCommentsCount
#               type
#               updatedAt
#               userAllowedToComment
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
      expect(response["participatoryProcess"]["components"].first).to eq(elections_data)
    end
  end
#
  describe "valid query" do
    let(:component_fragment) do
      %(
      fragment fooComponent on Elections {
        election(id: #{election.id}){
#           acceptsNewComments
#           author {
#             id
#           }
#           category {
#             id
#           }
#           comments {
#             id
#           }
#           commentsHaveAlignment
#           commentsHaveVotes
#           createdAt
#           description {
#             translation(locale: "#{locale}")
#           }
#           endTime
#           hasComments
#           id
#           image
#           informationUpdates {
#             translation(locale: "#{locale}")
#           }
#           instructions {
#             translation(locale: "#{locale}")
#           }
#           reference
#           startTime
#           title {
#             translation(locale: "#{locale}")
#           }
#           totalCommentsCount
#           type
#           updatedAt
#           userAllowedToComment
        }
      }
)
    end


    it "executes sucessfully" do
      expect { response }.not_to raise_error(StandardError)
    end

    it "" do
      expect(response["participatoryProcess"]["components"].first["election"]).to eq(election_single_result)
    end
  end
end
