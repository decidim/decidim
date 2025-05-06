# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"
require_relative "../shared/services_interface_examples"
require_relative "../shared/linked_resources_interface_examples"

module Decidim
  module Meetings
    describe MeetingType, type: :graphql do
      include_context "with a graphql class type"
      let(:current_component) { create(:meeting_component) }
      let(:component) { current_component }
      let(:model) { create(:meeting, :published, component:) }
      let(:organization) { component.organization }

      include_examples "authorable interface"
      include_examples "taxonomizable interface"
      include_examples "timestamps interface"
      include_examples "attachable interface"
      include_examples "services interface"
      include_examples "linked resources interface"
      include_examples "followable interface"
      include_examples "referable interface"
      include_examples "localizable interface"

      describe "id" do
        let(:query) { "{ id }" }

        it "returns the meeting's id" do
          expect(response["id"]).to eq(model.id.to_s)
        end
      end

      describe "comments_enabled" do
        let(:query) { "{ commentsEnabled }" }

        let(:model) { create(:meeting, :published, component:, comments_enabled: true) }

        it "displays the field value" do
          expect(response["commentsEnabled"]).to be true
        end
      end

      describe "comments_end_time" do
        let(:query) { "{ commentsEndTime }" }

        it "hides the field value" do
          expect(response["commentsEndTime"]).to be_nil
        end

        context "when is set" do
          let(:model) { create(:meeting, :published, component:, comments_end_time: Time.current.utc) }

          it "displays the field value" do
            expect(response["commentsEndTime"]).to eq(model.comments_end_time.to_time.iso8601)
          end
        end
      end

      describe "published_at" do
        let(:query) { "{ publishedAt }" }

        context "when is set" do
          let(:model) { create(:meeting, :published, component:) }

          it "returns the publishedAt field" do
            expect(response["publishedAt"]).to eq(model.published_at.to_time.iso8601)
          end
        end

        context "when is not set" do
          let(:model) { create(:meeting, component:) }

          it "returns the publishedAt field" do
            expect(response).to be_nil
          end
        end
      end

      describe "comments_start_time" do
        let(:query) { "{ commentsStartTime }" }

        it "hides the field value" do
          expect(response["commentsStartTime"]).to be_nil
        end

        context "when is set" do
          let(:model) { create(:meeting, :published, component:, comments_start_time: Time.current.utc) }

          it "displays the field value" do
            expect(response["commentsStartTime"]).to eq(model.comments_start_time.to_time.iso8601)
          end
        end
      end

      describe "iframe_access_level" do
        let(:query) { "{ iframeAccessLevel }" }
        let(:model) { create(:meeting, :published, component:, iframe_access_level: nil) }

        it "hides the field value" do
          expect(response["iframeAccessLevel"]).to be_nil
        end

        %w(all signed_in registered).each do |iframe_access_level|
          context "when is set to #{iframe_access_level}" do
            let(:model) { create(:meeting, :published, component:, iframe_access_level:) }

            it "displays the field value" do
              expect(response["iframeAccessLevel"]).to eq(model.iframe_access_level)
            end
          end
        end
      end

      describe "iframe_embed_type" do
        let(:query) { "{ iframeEmbedType }" }
        let(:model) { create(:meeting, :published, component:, iframe_embed_type: nil) }

        it "hides the field value" do
          expect(response["iframeEmbedType"]).to be_nil
        end

        %w(none embed_in_meeting_page open_in_live_event_page open_in_new_tab).each do |iframe_embed_type|
          context "when is set to #{iframe_embed_type}" do
            let(:model) { create(:meeting, :published, component:, iframe_embed_type:) }

            it "displays the field value" do
              expect(response["iframeEmbedType"]).to eq(model.iframe_embed_type)
            end
          end
        end
      end

      describe "registration_type" do
        let(:query) { "{ registrationType }" }

        %w(registration_disabled on_this_platform on_different_platform).each do |registration_type|
          context "when is set to #{registration_type}" do
            let(:model) { create(:meeting, :published, component:, registration_type:) }

            it "displays the field value" do
              expect(response["registrationType"]).to eq(model.registration_type)
            end
          end
        end
      end

      describe "public_participants" do
        let(:query) { "{ publicParticipants { id } }" }

        it "returns the public participant's id" do
          expect(response["publicParticipants"]).to eq(model.public_participants.map { |pp| { "id" => pp.id.to_s } })
        end
      end

      describe "registration_url" do
        let(:query) { "{ registrationUrl }" }
        let(:registration_url) { "http://decidim.org" }

        let(:model) { create(:meeting, :published, component:, registration_url:) }

        it "returns the public participant's id" do
          expect(response["registrationUrl"]).to eq(model.registration_url)
        end
      end

      describe "title" do
        let(:query) { "{ title { translation(locale: \"ca\") } }" }

        it "returns the meeting's title" do
          expect(response["title"]["translation"]).to eq(model.title["ca"])
        end
      end

      describe "customize_registration_email" do
        let(:query) { "{ customizeRegistrationEmail } " }

        it "returns the meeting's title" do
          expect(response["customizeRegistrationEmail"]).to be false
        end

        context "when customize_registration_email" do
          let(:model) { create(:meeting, :published, component:, customize_registration_email: false) }

          it "returns the meeting's title" do
            expect(response["customizeRegistrationEmail"]).to be false
          end
        end
      end

      describe "description" do
        let(:query) { "{ description { translation(locale: \"ca\") } }" }

        it "returns the meeting's description" do
          expect(response["description"]["translation"]).to eq(model.description["ca"])
        end
      end

      describe "startTime" do
        let(:query) { "{ startTime }" }

        it "returns the meeting's start time" do
          expect(Time.zone.parse(response["startTime"])).to be_within(1.second).of(model.start_time)
        end
      end

      describe "endTime" do
        let(:query) { "{ endTime }" }

        it "returns the meeting's end time" do
          expect(Time.zone.parse(response["endTime"])).to be_within(1.second).of(model.end_time)
        end
      end

      describe "isWithdrawn" do
        let(:query) { "{ isWithdrawn }" }

        context "when meetings is withdrawn" do
          let(:model) { create(:meeting, :published, :withdrawn, component:) }

          it "returns true" do
            expect(response["isWithdrawn"]).to be true
          end
        end

        context "when meetings is not withdrawn" do
          let(:model) { create(:meeting, :published, component:) }

          it "returns false" do
            expect(response["isWithdrawn"]).to be false
          end
        end
      end

      describe "closed" do
        let(:query) { "{ closedAt closed closingReport { translation(locale: \"ca\") } }" }

        it "hides the closing time" do
          expect(response["closedAt"]).to be_nil
        end

        context "when closed" do
          let(:model) { create(:meeting, :published, :closed, component:) }

          it "displays the closing time" do
            expect(response["closedAt"]).to eq(model.closed_at.to_time.iso8601)
          end

          it "returns true" do
            expect(response["closed"]).to be true
          end

          it "has a closing report" do
            expect(response["closingReport"]).not_to be_nil
            expect(response["closingReport"]["translation"]).to eq(model.closing_report["ca"])
          end
        end

        context "when closed with minutes" do
          let(:model) { create(:meeting, :published, :closed_with_minutes, closing_visible:, component:) }
          let(:query) { "{ closed closingReport { translation(locale: \"ca\") } }" }

          context "and closing_visible is true" do
            let(:closing_visible) { true }

            it "returns true" do
              expect(response["closed"]).to be true
            end

            it "has a closing report" do
              expect(response["closingReport"]).not_to be_nil
              expect(response["closingReport"]["translation"]).to eq(model.closing_report["ca"])
            end
          end

          context "and closing_visible is false" do
            let(:closing_visible) { false }

            it "returns true" do
              expect(response["closed"]).to be true
            end

            it "has a closing report" do
              expect(response["closingReport"]).to be_nil
            end
          end
        end

        context "when open" do
          let(:model) { create(:meeting, :published, component:) }

          it "returns false" do
            expect(response["closed"]).to be false
          end

          it "does not have a closing report" do
            expect(response["closingReport"]).to be_nil
          end
        end
      end

      describe "agenda" do
        let(:query) { "{ agenda { id items { id } } }" }
        let(:agenda) { create(:agenda, :with_agenda_items) }

        before do
          model.update(agenda:)
        end

        it "returns the agenda's items" do
          ids = response["agenda"]["items"].map { |item| item["id"] }
          expect(ids).to include(*model.agenda.agenda_items.map(&:id).map(&:to_s))
          expect(response["agenda"]["id"]).to eq(agenda.id.to_s)
        end
      end

      context "with registrations open" do
        let(:model) { create(:meeting, :published, :with_registrations_enabled, component:) }

        describe "registrationsEnabled" do
          let(:query) { "{ registrationsEnabled }" }

          it "returns true" do
            expect(response["registrationsEnabled"]).to be true
          end
        end

        describe "registrationTerms" do
          let(:query) { "{ registrationTerms { translation(locale: \"ca\") } }" }

          it "returns the meeting's registration_terms" do
            expect(response["registrationTerms"]["translation"]).to eq(model.registration_terms["ca"])
          end
        end

        describe "remainingSlots" do
          let(:query) { "{ remainingSlots }" }

          it "returns the amount of remaining slots" do
            expect(response["remainingSlots"]).to eq(model.remaining_slots)
          end
        end

        describe "attendeeCount" do
          let(:query) { "{ attendeeCount }" }

          it "returns the amount of attendees" do
            expect(response["attendeeCount"]).to eq(model.attendees_count)
          end
        end
      end

      describe "contributionCount" do
        let(:query) { "{ contributionCount }" }

        it "returns the amount of contributions" do
          expect(response["contributionCount"]).to eq(model.contributions_count)
        end
      end

      describe "location" do
        let(:query) { "{ location { translation(locale: \"ca\") } }" }

        it "returns the meeting's location" do
          expect(response["location"]["translation"]).to eq(model.location["ca"])
        end
      end

      describe "locationHints" do
        let(:query) { "{ locationHints { translation(locale: \"ca\") } }" }

        it "returns the meeting's location_hints" do
          expect(response["locationHints"]["translation"]).to eq(model.location_hints["ca"])
        end
      end

      describe "registrationFormEnabled" do
        let(:query) { "{ registrationFormEnabled }" }

        it "returns true" do
          expect(response["registrationFormEnabled"]).to be true
        end
      end

      describe "registrationForm" do
        let(:query) { "{ registrationForm { id } }" }

        it "returns the registrationForm's items" do
          expect(response["registrationForm"]["id"]).to eq(model.questionnaire.id.to_s)
        end
      end

      describe "privateMeeting" do
        let(:query) { "{ privateMeeting }" }

        it "returns true" do
          expect(response["privateMeeting"]).to be false
        end
      end

      context "when published meeting is private but transparent" do
        let(:model) { create(:meeting, :published, :not_official, :with_registrations_enabled, component:, private_meeting: true, transparent: true) }
        let(:query) { "{ privateMeeting }" }

        it "returns true" do
          expect(response["privateMeeting"]).to be true
        end
      end

      context "when meeting is private but transparent" do
        let(:model) { create(:meeting, :not_official, :published, private_meeting: true, transparent: true) }
        let(:current_user) { model.author }
        let(:query) { "{ id }" }
        let(:root_value) { model.reload }

        it "returns all the required fields" do
          expect(response["id"]).to eq(model.id.to_s)
        end
      end

      context "when meeting is private" do
        let(:model) { create(:meeting, :published, private_meeting: true, transparent: false) }
        let(:query) { "{ id }" }
        let(:root_value) { model.reload }
        let!(:current_user) { create(:user, :confirmed, organization: current_organization) }

        it "returns nothing" do
          expect(response).to be_nil
        end
      end

      describe "transparent" do
        let(:query) { "{ transparent }" }

        it "returns true" do
          expect(response["transparent"]).to be true
        end
      end

      context "when participatory space is private" do
        let(:participatory_space) { create(:participatory_process, :with_steps, :private, organization: current_organization) }
        let(:current_component) { create(:meeting_component, participatory_space:) }
        let(:model) { create(:meeting, component: current_component) }
        let(:query) { "{ id }" }

        it "returns nothing" do
          expect(response).to be_nil
        end
      end

      context "when participatory space is private but transparent" do
        let(:participatory_space) { create(:assembly, :private, :transparent, organization: current_organization) }
        let(:current_component) { create(:meeting_component, participatory_space:) }
        let(:model) { create(:meeting, :published, component: current_component) }
        let(:query) { "{ id }" }

        it "returns the model" do
          expect(response).to include("id" => model.id.to_s)
        end
      end

      context "when participatory space is not published" do
        let(:participatory_space) { create(:participatory_process, :with_steps, :unpublished, organization: current_organization) }
        let(:current_component) { create(:meeting_component, participatory_space:) }
        let(:model) { create(:meeting, component: current_component) }
        let(:query) { "{ id }" }

        it "returns nothing" do
          expect(response).to be_nil
        end
      end

      context "when component is not published" do
        let(:current_component) { create(:meeting_component, :unpublished, organization: current_organization) }
        let(:model) { create(:meeting, component: current_component) }
        let(:query) { "{ id }" }

        it "returns nothing" do
          expect(response).to be_nil
        end
      end

      context "when meeting is moderated" do
        let(:model) { create(:meeting, :hidden) }
        let(:query) { "{ id }" }
        let(:root_value) { model.reload }

        it "returns all the required fields" do
          expect(response).to be_nil
        end
      end

      context "when meeting is not published" do
        let(:model) { create(:meeting, published_at: nil) }
        let(:query) { "{ id }" }
        let(:root_value) { model.reload }

        it "returns nothing" do
          expect(response).to be_nil
        end
      end
    end
  end
end
