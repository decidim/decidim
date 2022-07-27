# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/component_context"
require "decidim/proposals/test/factories"

describe "Decidim::Api::QueryType" do
  include_context "with a graphql decidim component"
  let(:component_type) { "Proposals" }
  let!(:current_component) { create :proposal_component, participatory_space: participatory_process }
  let!(:proposal) { create(:proposal, :with_votes, :with_endorsements, :participant_author, component: current_component, category:) }
  let!(:amendments) { create_list(:proposal_amendment, 5, amendable: proposal, emendation: proposal) }

  let(:proposal_single_result) do
    proposal.reload
    {
      "acceptsNewComments" => proposal.accepts_new_comments?,
      "address" => proposal.address,
      "amendments" => proposal.amendments.map do |a|
        {
          "amendable" => { "id" => a.amendable.id.to_s },
          "amendableType" => a.amendable.class.name,
          "amender" => { "id" => a.amender.id.to_s },
          "emendation" => { "id" => a.emendation.id.to_s },
          "emendationType" => a.emendation.class.name,
          "id" => a.id.to_s,
          "state" => a.state
        }
      end,
      "answer" => nil,
      "answeredAt" => nil,
      "attachments" => [],
      "author" => { "id" => proposal.authors.first.id.to_s },
      "authors" => proposal.authors.map { |a| { "id" => a.id.to_s } },
      "authorsCount" => proposal.authors.size,
      "body" => { "translation" => proposal.body[locale] },
      "category" => { "id" => proposal.category.id.to_s },
      "comments" => [],
      "commentsHaveAlignment" => proposal.comments_have_alignment?,
      "commentsHaveVotes" => proposal.comments_have_votes?,
      "coordinates" => { "latitude" => proposal.latitude, "longitude" => proposal.longitude },
      "createdAt" => proposal.created_at.iso8601.to_s.gsub("Z", "+00:00"),
      "createdInMeeting" => proposal.created_in_meeting?,
      "endorsements" => proposal.endorsements.map do |e|
        { "deleted" => e.author.deleted?,
          "id" => e.author.id.to_s,
          "name" => e.author.name,
          "nickname" => "@#{e.author.nickname}",
          "organizationName" => e.author.organization.name,
          "profilePath" => "/profiles/#{e.author.nickname}" }
      end,
      "endorsementsCount" => proposal.endorsements.size,
      "fingerprint" => { "source" => proposal.fingerprint.source, "value" => proposal.fingerprint.value },
      "hasComments" => proposal.comment_threads.size.positive?,
      "id" => proposal.id.to_s,
      "meeting" => nil,
      "official" => proposal.official?,
      "participatoryTextLevel" => proposal.participatory_text_level,
      "position" => proposal.position,
      "publishedAt" => proposal.published_at.iso8601.to_s.gsub("Z", "+00:00"),
      "reference" => proposal.reference,
      "scope" => proposal.scope,
      "state" => proposal.state,
      "title" => { "translation" => proposal.title[locale] },
      "totalCommentsCount" => proposal.comments_count,
      "type" => "Decidim::Proposals::Proposal",
      "updatedAt" => proposal.updated_at.iso8601.to_s.gsub("Z", "+00:00"),
      "userAllowedToComment" => proposal.user_allowed_to_comment?(current_user),
      "versions" => [],
      "versionsCount" => 0,
      "voteCount" => proposal.votes.size
    }
  end

  let(:proposals_data) do
    {
      "__typename" => "Proposals",
      "id" => current_component.id.to_s,
      "name" => { "translation" => "Proposals" },
      "proposals" => {
        "edges" => [
          {
            "node" => proposal_single_result
          }
        ]
      },
      "weight" => 0
    }
  end

  describe "valid connection query" do
    let(:component_fragment) do
      %(
      fragment fooComponent on Proposals {
        proposals {
          edges{
            node{
              acceptsNewComments
              address
              amendments {
                id
                state
                amender { id }
                amendable { id }
                emendation { id }
                emendationType
                amendableType
              }
              answer {
                translation(locale:"#{locale}")
              }
              answeredAt
              attachments {
                thumbnail
              }
              author {
                id
              }
              authors {
                id
              }
              authorsCount
              body {
                translation(locale:"#{locale}")
              }
              category {
                id
              }
              comments {
                id
              }
              commentsHaveAlignment
              commentsHaveVotes
              coordinates{
                latitude
                longitude
              }
              createdAt
              createdInMeeting
              endorsements {
                id
                deleted
                 name
                nickname
                organizationName
                profilePath
              }
              endorsementsCount
              fingerprint{
                source
                value
              }
              hasComments
              id
              meeting {
                id
              }
              official
              participatoryTextLevel
              position
              publishedAt
              reference
              scope {
                id
              }
              state
              title {
                translation(locale:"#{locale}")
              }
              totalCommentsCount
              type
              updatedAt
              userAllowedToComment
              versions {
                id
                changeset
                createdAt
                editor{
                  id
                }
              }
              versionsCount
              voteCount
            }
          }
        }
      }
    )
    end

    it "executes sucessfully" do
      expect { response }.not_to raise_error
    end
  end

  describe "valid query" do
    let(:component_fragment) do
      %(
      fragment fooComponent on Proposals {
        proposal(id: #{proposal.id}) {
          acceptsNewComments
          address
          amendments {
            id
            state
            amender { id }
            amendable { id }
            emendation { id }
            emendationType
            amendableType
          }
          answer {
            translation(locale:"#{locale}")
          }
          answeredAt
          attachments {
            thumbnail
          }
          author {
            id
          }
          authors {
            id
          }
          authorsCount
          body {
            translation(locale:"#{locale}")
          }
          category {
            id
          }
          comments {
            id
          }
          commentsHaveAlignment
          commentsHaveVotes
          coordinates{
            latitude
            longitude
          }
          createdAt
          createdInMeeting
          endorsements {
            id
            deleted
             name
            nickname
            organizationName
            profilePath
          }
          endorsementsCount
          fingerprint{
            source
            value
          }
          hasComments
          id
          meeting {
            id
          }
          official
          participatoryTextLevel
          position
          publishedAt
          reference
          scope {
            id
          }
          state
          title {
            translation(locale:"#{locale}")
          }
          totalCommentsCount
          type
          updatedAt
          userAllowedToComment
          versions {
            id
            changeset
            createdAt
            editor{
              id
            }
          }
          versionsCount
          voteCount
        }
      }
    )
    end

    it "executes sucessfully" do
      expect { response }.not_to raise_error
    end

    it do
      expect(response["participatoryProcess"]["components"].first["proposal"]).to eq(proposal_single_result)
    end
  end
end
