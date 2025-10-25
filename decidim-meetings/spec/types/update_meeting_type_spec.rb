# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/mutation_context"

module Decidim
  module Meetings
    describe UpdateMeetingType, type: :graphql do
      include_context "with a graphql class mutation"

      let(:root_klass) { MeetingMutationType }
      let(:organization) { create(:organization, available_locales: [:en]) }
      let(:participatory_process) { create(:participatory_process, :with_steps, organization:) }
      let(:meeting_component) { create(:meeting_component, participatory_space: participatory_process) }
      let!(:model) { create(:meeting, component: meeting_component, author: user) }
      let(:title) { { en: "Updated Meeting Title" } }
      let(:description) { { en: "Updated meeting description" } }
      let(:location) { { en: "Updated location" } }
      let(:start_time) { 2.days.from_now }
      let(:end_time) { 2.days.from_now + 2.hours }
      let(:component) { model.component }
      let(:address) { "Updated address, 123" }
      let(:latitude) { 41.1234 }
      let(:longitude) { 2.5678 }
      let(:registration_type) { "on_this_platform" }
      let(:available_slots) { 50 }
      let(:type_of_meeting) { "online" }
      let(:online_meeting_url) { "https://meet.example.org/updated-meeting" }
      let(:registration_terms) { { en: "Updated registration terms" } }

      let(:variables) do
        {
          input: {
            attributes: {
              title:,
              description:,
              location:,
              startTime: start_time.iso8601,
              endTime: end_time.iso8601,
              address:,
              latitude:,
              longitude:,
              registrationType: registration_type,
              availableSlots: available_slots,
              typeOfMeeting: type_of_meeting,
              onlineMeetingUrl: online_meeting_url,
              registrationTerms:
            }
          }
        }
      end

      let(:query) do
        <<~GRAPHQL
          mutation($input: UpdateMeetingInput!) {
            update(input: $input) {
              id
              title { translation(locale: "en") }
              description { translation(locale: "en") }
              location { translation(locale: "en") }
              startTime
              endTime
              address
              registrationType
            }
          }
        GRAPHQL
      end

      context "with user who owns the meeting" do
        it_behaves_like "update meeting mutation examples" do
          let!(:user_type) { :user }
        end
      end

      context "with admin user" do
        it_behaves_like "update meeting mutation examples" do
          let!(:user_type) { :admin }
        end
      end

      context "with api_user" do
        it_behaves_like "update meeting mutation examples" do
          let!(:user_type) { :api_user }
        end
      end

      context "with user who does not own the meeting" do
        let(:other_user) { create(:user, :confirmed, organization:) }
        let(:user) { other_user }

        it "returns nil" do
          expect(response["update"]).to be_nil
        end
      end
    end
  end
end
