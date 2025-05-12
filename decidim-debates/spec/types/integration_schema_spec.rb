# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

describe "Decidim::Api::QueryType" do
  include_context "with a graphql decidim component" do
    let(:component_fragment) do
      %(
      fragment fooComponent on Debates {
        debate(id: #{debate.id}){
          acceptsNewComments
          attachments {
            thumbnail
          }
          author {
            id
          }
          closedAt
          comments {
            id
          }
          commentsEnabled
          commentsHaveAlignment
          commentsHaveVotes
          conclusions { translation(locale:"#{locale}") }
          createdAt
          description {
            translation(locale: "#{locale}")
          }
          endorsementsCount
          endTime
          followsCount
          hasComments
          id
          image
          informationUpdates {
            translation(locale: "#{locale}")
          }
          instructions {
            translation(locale: "#{locale}")
          }
          lastCommentAt
          lastCommentBy { id }
          reference
          startTime
          taxonomies {
            id
          }
          title {
            translation(locale: "#{locale}")
          }
          totalCommentsCount
          type
          updatedAt
          url
          userAllowedToComment
        }
      }
)
    end
  end
  let(:component_type) { "Debates" }

  let!(:current_component) { create(:debates_component, participatory_space: participatory_process) }
  let(:author) { build(:user, :confirmed, organization: current_component.organization) }
  let(:last_comment_by) { create(:user, :confirmed, name: "User") }
  let!(:debate) do
    create(:debate, :closed, :with_endorsements, :participant_author,
           author:,
           component: current_component,
           taxonomies:,
           last_comment_at: 1.year.ago,
           last_comment_by:,
           comments_enabled: true)
  end
  let!(:follows) { create_list(:follow, 3, followable: debate) }

  let(:debate_single_result) do
    {
      "acceptsNewComments" => debate.accepts_new_comments?,
      "attachments" => [],
      "author" => { "id" => debate.author.id.to_s },
      "closedAt" => debate.closed_at.to_time.iso8601,
      "comments" => [],
      "commentsEnabled" => true,
      "commentsHaveAlignment" => debate.comments_have_alignment?,
      "commentsHaveVotes" => debate.comments_have_votes?,
      "conclusions" => { "translation" => translated(debate.conclusions) },
      "createdAt" => debate.created_at.to_time.iso8601,
      "description" => { "translation" => debate.description[locale] },
      "endorsementsCount" => 5,
      "endTime" => debate.end_time,
      "followsCount" => 3,
      "hasComments" => debate.comment_threads.size.positive?,
      "id" => debate.id.to_s,
      "image" => nil,
      "informationUpdates" => { "translation" => debate.information_updates[locale] },
      "instructions" => { "translation" => debate.instructions[locale] },
      "lastCommentAt" => debate.last_comment_at.to_time.iso8601,
      "lastCommentBy" => { "id" => last_comment_by.id.to_s },
      "reference" => debate.reference,
      "startTime" => debate.start_time,
      "taxonomies" => [{ "id" => debate.taxonomies.first.id.to_s }],
      "title" => { "translation" => debate.title[locale] },
      "totalCommentsCount" => debate.comments_count,
      "type" => "Decidim::Debates::Debate",
      "updatedAt" => debate.updated_at.to_time.iso8601,
      "url" => Decidim::ResourceLocatorPresenter.new(debate).url,
      "userAllowedToComment" => debate.user_allowed_to_comment?(current_user)
    }
  end

  let(:debates_data) do
    {
      "__typename" => "Debates",
      "id" => current_component.id.to_s,
      "name" => { "translation" => translated(current_component.name) },
      "debates" => {
        "edges" => [
          {
            "node" => debate_single_result
          }
        ]
      },
      "url" => Decidim::EngineRouter.main_proxy(current_component).root_url,
      "weight" => 0
    }
  end

  describe "commentable" do
    let(:component_fragment) { nil }

    let(:participatory_process_query) do
      %(
        commentable(id: "#{debate.id}", type: "Decidim::Debates::Debate", locale: "en", toggleTranslations: false) {
          __typename
        }
      )
    end

    it "executes successfully" do
      expect { response }.not_to raise_error
    end

    it do
      expect(response).to eq({ "commentable" => { "__typename" => "Debate" } })
    end
  end

  describe "valid connection query" do
    let(:component_fragment) do
      %(
      fragment fooComponent on Debates {
        debates{
          edges{
            node{
              acceptsNewComments
              attachments {
                thumbnail
              }
              author {
                id
              }
              closedAt
              comments {
                id
              }
              commentsEnabled
              commentsHaveAlignment
              commentsHaveVotes
              conclusions { translation(locale:"#{locale}") }
              createdAt
              description {
                translation(locale: "#{locale}")
              }
              endorsementsCount
              endTime
              followsCount
              hasComments
              id
              image
              informationUpdates {
                translation(locale: "#{locale}")
              }
              instructions {
                translation(locale: "#{locale}")
              }
              lastCommentAt
              lastCommentBy { id }
              reference
              startTime
              taxonomies {
                id
              }
              title {
                translation(locale: "#{locale}")
              }
              totalCommentsCount
              type
              updatedAt
              url
              userAllowedToComment
            }
          }
        }
      }
)
    end

    it "executes successfully" do
      expect { response }.not_to raise_error
    end

    it do
      expect(response["participatoryProcess"]["components"].first).to eq(debates_data)
    end
  end

  describe "valid query" do
    it "executes successfully" do
      expect { response }.not_to raise_error
    end

    it do
      expect(response["participatoryProcess"]["components"].first["debate"]).to eq(debate_single_result)
    end
  end

  include_examples "with resource visibility" do
    let(:component_factory) { :debates_component }
    let(:lookout_key) { "debate" }
    let(:query_result) { debate_single_result }
  end
end
