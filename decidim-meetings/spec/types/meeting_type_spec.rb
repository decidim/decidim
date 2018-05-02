# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"
require "decidim/core/test/shared_examples/categorizable_interface_examples"
require "decidim/core/test/shared_examples/scopable_interface_examples"
require "decidim/core/test/shared_examples/attachable_interface_examples"
require "decidim/core/test/shared_examples/authorable_interface_examples"

module Decidim
  module Meetings
    describe MeetingType, type: :graphql do
      include_context "with a graphql type"
      let(:component) { create(:meeting_component) }
      let(:model) { create(:meeting, component: component) }

      include_examples "categorizable interface"
      include_examples "scopable interface"
      include_examples "attachable interface"

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

      describe "closed" do
        let(:query) { "{ closed closingReport { translation(locale: \"ca\") } }" }

        context "when closed" do
          let(:model) { create(:meeting, :closed, component: component) }

          it "returns true" do
            expect(response["closed"]).to be true
          end

          it "has a closing report" do
            expect(response["closingReport"]).not_to be_nil
            expect(response["closingReport"]["translation"]).to eq(model.closing_report["ca"])
          end
        end

        context "when open" do
          let(:model) { create(:meeting, component: component) }

          it "returns false" do
            expect(response["closed"]).to be false
          end

          it "doesn't have a closing report" do
            expect(response["closingReport"]).to be_nil
          end
        end
      end

      context "with registrations open" do
        let(:model) { create(:meeting, :with_registrations_enabled, component: component) }

        describe "registrationsEnabled" do
          let(:query) { "{ registrationsEnabled }" }

          it "returns true" do
            expect(response["registrationsEnabled"]).to be true
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
    end
  end
end
