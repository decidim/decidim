# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"
require "decidim/core/test/shared_examples/categorizable_interface_examples"
require "decidim/core/test/shared_examples/scopable_interface_examples"
require "decidim/core/test/shared_examples/attachable_interface_examples"
require "decidim/core/test/shared_examples/authorable_interface_examples"
require "decidim/core/test/shared_examples/timestamps_interface_examples"
require "shared/services_interface_examples"
require "shared/linked_resources_interface_examples"

module Decidim
  module Meetings
    describe MeetingType, type: :graphql do
      include_context "with a graphql class type"
      let(:component) { create(:meeting_component) }
      let(:model) { create(:meeting, component:) }

      include_examples "authorable interface"
      include_examples "categorizable interface"
      include_examples "timestamps interface"
      include_examples "scopable interface"
      include_examples "attachable interface"
      include_examples "services interface"
      include_examples "linked resources interface"

      describe "id" do
        let(:query) { "{ id }" }

        it "returns the meeting's id" do
          expect(response["id"]).to eq(model.id.to_s)
        end
      end

      describe "reference" do
        let(:query) { "{ reference }" }

        it "returns the meeting's reference" do
          expect(response["reference"]).to eq(model.reference.to_s)
        end
      end

      describe "title" do
        let(:query) { "{ title { translation(locale: \"ca\") } }" }

        it "returns the meeting's title" do
          expect(response["title"]["translation"]).to eq(model.title["ca"])
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
          let(:model) { create(:meeting, :withdrawn, component:) }

          it "returns true" do
            expect(response["isWithdrawn"]).to be true
          end
        end

        context "when meetings is not withdrawn" do
          let(:model) { create(:meeting, component:) }

          it "returns false" do
            expect(response["isWithdrawn"]).to be false
          end
        end
      end

      describe "closed" do
        let(:query) { "{ closed closingReport { translation(locale: \"ca\") } }" }

        context "when closed" do
          let(:model) { create(:meeting, :closed, component:) }

          it "returns true" do
            expect(response["closed"]).to be true
          end

          it "has a closing report" do
            expect(response["closingReport"]).not_to be_nil
            expect(response["closingReport"]["translation"]).to eq(model.closing_report["ca"])
          end
        end

        context "when closed with minutes" do
          let(:model) { create(:meeting, :closed_with_minutes, closing_visible:, component:) }
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
          let(:model) { create(:meeting, component:) }

          it "returns false" do
            expect(response["closed"]).to be false
          end

          it "doesn't have a closing report" do
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
        let(:model) { create(:meeting, :with_registrations_enabled, component:) }

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

      describe "address" do
        let(:query) { "{ address }" }

        it "returns the meeting's address" do
          expect(response["address"]).to eq(model.address)
        end
      end

      describe "coordinates" do
        let(:query) { "{ coordinates { latitude longitude } }" }

        it "returns the meeting's address" do
          expect(response["coordinates"]).to include(
            "latitude" => model.latitude,
            "longitude" => model.longitude
          )
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

      context "when meeting is private" do
        let(:query) { "{ privateMeeting }" }

        before do
          model.update(private_meeting: true, transparent: false)
        end

        it "returns true" do
          expect(response["privateMeeting"]).to be true
        end
      end

      describe "transparent" do
        let(:query) { "{ transparent }" }

        it "returns true" do
          expect(response["transparent"]).to be true
        end
      end
    end
  end
end
