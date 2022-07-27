# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Conferences
    module Admin
      describe RegistrationTypeForm do
        subject(:form) { described_class.from_params(attributes).with_context(context) }

        let(:organization) { create :organization }
        let(:conference) { create :conference, organization: }
        let(:current_participatory_space) { conference }
        let(:context) do
          {
            current_participatory_space: conference,
            current_organization: organization
          }
        end

        let(:meeting_component) do
          create(:component, manifest_name: :meetings, participatory_space: conference)
        end

        let(:meetings) do
          create_list(
            :meeting,
            3,
            component: meeting_component
          )
        end

        let(:conference_meetings) do
          meetings.each do |meeting|
            meeting.becomes(Decidim::ConferenceMeeting)
          end
        end

        let(:conference_meeting_ids) { conference_meetings.map(&:id) }

        let(:title) { Decidim::Faker::Localized.sentence }
        let(:weight) { 1 }
        let(:price) { 300.00 }
        let(:description) do
          {
            en: "Description",
            es: "Descripción",
            ca: "Descripció"
          }
        end
        let(:attributes) do
          {
            "conference_registration_type" => {
              "title" => title,
              "weight" => weight,
              "description" => description,
              "price" => price,
              "conference_meeting_ids" => conference_meeting_ids
            }
          }
        end

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end

        context "when title is missing" do
          let(:title) { nil }

          it { is_expected.to be_invalid }
        end

        context "when weight is missing" do
          let(:weight) { nil }

          it { is_expected.to be_invalid }
        end

        context "when description is missing" do
          let(:description) { nil }

          it { is_expected.to be_invalid }
        end

        context "when price is missing" do
          let(:price) { nil }

          it { is_expected.to be_valid }
        end

        context "when price is not number" do
          let(:price) { "blabla" }

          # The value is cast to the correct type so "blabla" becomes 0.0 which
          # is valid.
          it { is_expected.to be_valid }
        end
      end
    end
  end
end
