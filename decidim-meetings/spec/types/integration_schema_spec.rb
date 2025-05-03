# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

describe "Decidim::Api::QueryType" do
  include_context "with a graphql decidim component" do
    let(:component_fragment) do
      %(
      fragment fooComponent on Meetings {
        meeting(id: #{meeting.id}){
          acceptsNewComments
          address
          agenda {
            id
          }
          attachments {
            thumbnail
          }
          attendeeCount
          attendingOrganizations
          taxonomies {
            id
          }
          closed
          closingReport {
            translation(locale: "#{locale}")
          }
          isWithdrawn
          videoUrl
          audioUrl
          comments {
            id
          }
          commentsHaveAlignment
          commentsHaveVotes
          contributionCount
          coordinates {
            latitude
            longitude
          }
          createdAt
          description {
            translation(locale: "#{locale}")
          }
          endTime
          hasComments
          id
          location {
            translation(locale: "#{locale}")
          }
          locationHints {
            translation(locale: "#{locale}")
          }
          privateMeeting
          proposalsFromMeeting {
            id
          }
          reference
          registrationForm {
            id
          }
          registrationsEnabled
          registrationTerms {
            translation(locale: "#{locale}")
          }
          registrationsEnabled
          remainingSlots
          services{
            description {
              translation(locale: "#{locale}")
            }
            title {
              translation(locale: "#{locale}")
            }
          }
          startTime
          title {
            translation(locale: "#{locale}")
          }
          totalCommentsCount
          transparent
          type
          updatedAt
          url
          userAllowedToComment
        }
      }
)
    end
  end
  let(:component_type) { "Meetings" }

  let!(:current_component) { create(:meeting_component, participatory_space: participatory_process) }
  let!(:meeting) { create(:meeting, :published, :withdrawn, :not_official, :with_services, :closed_with_minutes, closing_visible:, component: current_component, taxonomies:) }
  let!(:agenda) { create(:agenda, :with_agenda_items, meeting:) }
  let!(:invite) { create(:invite, :accepted, meeting:) }
  let(:closing_visible) { true }

  let(:meeting_single_result) do
    meeting.reload
    {
      "acceptsNewComments" => meeting.accepts_new_comments?,
      "address" => meeting.address,
      "agenda" => { "id" => meeting.agenda.id.to_s },
      "attachments" => [],
      "attendeeCount" => meeting.attendees_count,
      "attendingOrganizations" => meeting.attending_organizations,
      "taxonomies" => [{ "id" => meeting.taxonomies.first.id.to_s }],
      "closed" => true,
      "closingReport" => closing_visible ? { "translation" => meeting.closing_report[locale] } : nil,
      "isWithdrawn" => true,
      "videoUrl" => closing_visible ? meeting.video_url : nil,
      "audioUrl" => closing_visible ? meeting.audio_url : nil,
      "comments" => [],
      "commentsHaveAlignment" => meeting.comments_have_alignment?,
      "commentsHaveVotes" => meeting.comments_have_votes?,
      "contributionCount" => meeting.contributions_count,
      "coordinates" => {
        "latitude" => meeting.latitude.to_f,
        "longitude" => meeting.longitude.to_f
      },
      "createdAt" => meeting.created_at.to_time.iso8601,
      "description" => { "translation" => meeting.description[locale] },
      "endTime" => meeting.end_time.to_time.iso8601,
      "hasComments" => meeting.comment_threads.size.positive?,
      "id" => meeting.id.to_s,
      "location" => { "translation" => meeting.location[locale] },
      "locationHints" => { "translation" => meeting.location_hints[locale] },
      "privateMeeting" => false,
      "proposalsFromMeeting" => [],
      "reference" => meeting.reference,
      "registrationForm" => { "id" => meeting.questionnaire.id.to_s },
      "registrationTerms" => { "translation" => meeting.registration_terms[locale] },
      "registrationsEnabled" => false,
      "remainingSlots" => 0,
      "services" => meeting.services.map do |s|
        {
          "description" => { "translation" => s.description[locale] },
          "title" => { "translation" => s.title[locale] }
        }
      end,
      "startTime" => meeting.start_time.to_time.iso8601,
      "title" => { "translation" => meeting.title[locale] },
      "totalCommentsCount" => meeting.comments_count,
      "transparent" => meeting.transparent?,
      "type" => "Decidim::Meetings::Meeting",
      "updatedAt" => meeting.updated_at.to_time.iso8601,
      "url" => Decidim::ResourceLocatorPresenter.new(meeting).url,
      "userAllowedToComment" => meeting.user_allowed_to_comment?(current_user)
    }
  end

  let(:meeting_data) do
    {
      "__typename" => "Meetings",
      "id" => current_component.id.to_s,
      "name" => { "translation" => translated(current_component.name) },
      "meetings" => {
        "edges" => [
          {
            "node" => meeting_single_result
          }
        ]
      },
      "weight" => 0
    }
  end

  describe "commentable" do
    let(:component_fragment) { nil }

    let(:participatory_process_query) do
      %(
        commentable(id: "#{meeting.id}", type: "Decidim::Meetings::Meeting", locale: "en", toggleTranslations: false) {
          __typename
        }
      )
    end

    it "executes successfully" do
      expect { response }.not_to raise_error
    end

    it do
      expect(response).to eq({ "commentable" => { "__typename" => "Meeting" } })
    end
  end

  describe "valid connection query" do
    let(:component_fragment) do
      %(
      fragment fooComponent on Meetings {
        meetings{
          edges{
            node{
              acceptsNewComments
              address
              agenda {
                id
              }
              attachments {
                thumbnail
              }
              attendeeCount
              attendingOrganizations
              taxonomies {
                id
              }
              closed
              closingReport {
                translation(locale: "#{locale}")
              }
              isWithdrawn
              videoUrl
              audioUrl
              comments {
                id
              }
              commentsHaveAlignment
              commentsHaveVotes
              contributionCount
              coordinates {
                latitude
                longitude
              }
              createdAt
              description {
                translation(locale: "#{locale}")
              }
              endTime
              hasComments
              id
              location {
                translation(locale: "#{locale}")
              }
              locationHints {
                translation(locale: "#{locale}")
              }
              privateMeeting
              proposalsFromMeeting {
                id
              }
              reference
              registrationForm {
                id
              }
              registrationsEnabled
              registrationTerms {
                translation(locale: "#{locale}")
              }
              registrationsEnabled
              remainingSlots
              services{
                description {
                  translation(locale: "#{locale}")
                }
                title {
                  translation(locale: "#{locale}")
                }
              }
              startTime
              title {
                translation(locale: "#{locale}")
              }
              totalCommentsCount
              transparent
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

    it { expect(response["participatoryProcess"]["components"].first).to eq(meeting_data) }
  end

  describe "valid query" do
    it "executes successfully" do
      expect { response }.not_to raise_error
    end

    it { expect(response["participatoryProcess"]["components"].first["meeting"]).to eq(meeting_single_result) }

    context "when minutes is not visible" do
      let(:closing_visible) { false }

      it "executes successfully" do
        expect { response }.not_to raise_error
      end

      it { expect(response["participatoryProcess"]["components"].first["meeting"]).to eq(meeting_single_result) }
    end
  end

  include_examples "with resource visibility" do
    let(:component_factory) { :meeting_component }
    let(:lookout_key) { "meeting" }
    let(:query_result) { meeting_single_result }
  end
end
