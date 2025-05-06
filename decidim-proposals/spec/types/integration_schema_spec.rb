# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"
require "decidim/proposals/test/factories"

describe "Decidim::Api::QueryType" do
  include ActiveSupport::NumberHelper

  include_context "with a graphql decidim component" do
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
          cost
          costReport {
            translation(locale:"#{locale}")
          }
          taxonomies {
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
            organizationName { translation(locale: "#{locale}") }
            profilePath
          }
          endorsementsCount
          executionPeriod {
            translation(locale:"#{locale}")
          }
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
          proposalState {
            announcementTitle { translation(locale: "#{locale}") }
            bgColor
            id
            proposalsCount
            textColor
            title { translation(locale: "#{locale}") }
          }
          publishedAt
          reference
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
          withdrawn
          withdrawnAt
        }
      }
    )
    end
  end
  let(:component_type) { "Proposals" }
  let(:active_step) { current_component.participatory_space.respond_to?(:active_step) && current_component.participatory_space.active_step.present? }
  let(:cost) do
    number_to_currency(proposal.cost, unit: Decidim.currency_unit) if active_step
  end
  let(:cost_report) do
    { "translation" => translated(proposal.cost_report) } if active_step
  end
  let(:execution_period) do
    { "translation" => translated(proposal.execution_period) } if active_step
  end
  let(:proposal_state) do
    {
      "announcementTitle" => { "translation" => translated(proposal.proposal_state.announcement_title) },
      "bgColor" => proposal.proposal_state.bg_color,
      "id" => proposal.proposal_state.id.to_s,
      "proposalsCount" => proposal.proposal_state.proposals_count,
      "textColor" => proposal.proposal_state.text_color,
      "title" => { "translation" => translated(proposal.proposal_state.title) }
    }
  end

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
      "answer" => { "translation" => translated(proposal.answer) },
      "answeredAt" => proposal.answered_at.to_time.iso8601,
      "attachments" => [],
      "author" => { "id" => proposal.authors.first.id.to_s },
      "authors" => proposal.authors.map { |a| { "id" => a.id.to_s } },
      "authorsCount" => proposal.authors.size,
      "body" => { "translation" => proposal.body[locale] },
      "taxonomies" => [{ "id" => proposal.taxonomies.first.id.to_s }],
      "comments" => [],
      "commentsHaveAlignment" => proposal.comments_have_alignment?,
      "commentsHaveVotes" => proposal.comments_have_votes?,
      "coordinates" => { "latitude" => proposal.latitude, "longitude" => proposal.longitude },
      "cost" => cost,
      "costReport" => cost_report,
      "createdAt" => proposal.created_at.to_time.iso8601,
      "createdInMeeting" => proposal.created_in_meeting?,
      "endorsements" => proposal.endorsements.map do |e|
        { "deleted" => e.author.deleted?,
          "id" => e.author.id.to_s,
          "name" => e.author.name,
          "nickname" => "@#{e.author.nickname}",
          "organizationName" => { "translation" => translated(e.author.organization.name) },
          "profilePath" => "/profiles/#{e.author.nickname}" }
      end,
      "endorsementsCount" => proposal.endorsements.size,
      "executionPeriod" => execution_period,
      "fingerprint" => { "source" => proposal.fingerprint.source, "value" => proposal.fingerprint.value },
      "hasComments" => proposal.comment_threads.size.positive?,
      "id" => proposal.id.to_s,
      "meeting" => nil,
      "official" => proposal.official?,
      "participatoryTextLevel" => proposal.participatory_text_level,
      "position" => proposal.position,
      "proposalState" => proposal_state,
      "publishedAt" => proposal.published_at.to_time.iso8601,
      "reference" => proposal.reference,
      "state" => proposal.state,
      "title" => { "translation" => proposal.title[locale] },
      "totalCommentsCount" => proposal.comments_count,
      "type" => "Decidim::Proposals::Proposal",
      "updatedAt" => proposal.updated_at.to_time.iso8601,
      "userAllowedToComment" => proposal.user_allowed_to_comment?(current_user),
      "versions" => [],
      "versionsCount" => 0,
      "voteCount" => proposal.votes.size,
      "withdrawn" => proposal.withdrawn?,
      "withdrawnAt" => proposal.withdrawn_at&.to_time&.iso8601
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
  let(:organization) { participatory_process.organization }
  let!(:current_component) { create(:proposal_component, participatory_space: participatory_process) }
  let!(:proposal) { create(:proposal, :with_answer, :with_votes, :with_endorsements, :participant_author, component: current_component, taxonomies:) }
  let!(:amendments) { create_list(:proposal_amendment, 5, amendable: proposal, emendation: proposal) }

  before do
    if active_step
      current_component.update!(
        settings: { proposal_answering_enabled: true },
        step_settings: {
          current_component.participatory_space.active_step.id => {
            proposal_answering_enabled: true,
            answers_with_costs: true
          }
        }
      )
    end
  end

  describe "commentable" do
    let(:component_fragment) { nil }
    let(:participatory_process_query) do
      %(
        commentable(id: "#{proposal.id}", type: "Decidim::Proposals::Proposal", locale: "en", toggleTranslations: false) {
          __typename
        }
      )
    end

    it "executes successfully" do
      expect { response }.not_to raise_error
    end

    it do
      expect(response).to eq({ "commentable" => { "__typename" => "Proposal" } })
    end
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
              taxonomies {
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
                organizationName { translation(locale: "en") }
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
              proposalState {
                announcementTitle { translation(locale: "#{locale}") }
                bgColor
                id
                proposalsCount
                textColor
                title { translation(locale: "#{locale}") }
              }
              publishedAt
              reference
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
              withdrawn
              withdrawnAt
            }
          }
        }
      }
    )
    end

    it "executes successfully" do
      expect { response }.not_to raise_error
    end
  end

  describe "valid query" do
    it "executes successfully" do
      expect { response }.not_to raise_error
    end

    it do
      expect(response["participatoryProcess"]["components"].first["proposal"]).to eq(proposal_single_result)
    end
  end

  include_examples "with resource visibility" do
    let(:component_factory) { :proposal_component }
    let(:lookout_key) { "proposal" }
    let(:query_result) { proposal_single_result }
  end
end
