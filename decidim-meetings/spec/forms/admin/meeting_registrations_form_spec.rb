# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe Admin::MeetingRegistrationsForm do
    subject { described_class.from_params(attributes).with_context(context) }

    let(:meeting) { create(:meeting) }
    let(:attributes) do
      {
        registrations_enabled:,
        available_slots:,
        reserved_slots:,
        registration_terms:
      }
    end
    let(:registrations_enabled) { true }
    let(:available_slots) { 10 }
    let(:reserved_slots) { 2 }
    let(:registration_terms) do
      {
        en: "A legal text",
        es: "Un texto legal",
        ca: "Un text legal"
      }
    end
    let(:context) { { current_organization: meeting.organization, meeting: } }

    it { is_expected.to be_valid }

    context "when registrations are not enabled" do
      let(:registrations_enabled) { false }

      context "and the registration terms are blank" do
        let(:registration_terms) do
          {
            en: "",
            es: "",
            ca: ""
          }
        end

        it { is_expected.to be_valid }
      end
    end

    context "when registrations are enabled" do
      context "and the registration terms are blank" do
        let(:registration_terms) do
          {
            en: "",
            es: "",
            ca: ""
          }
        end

        it { is_expected.not_to be_valid }
      end
    end

    context "when the available slots is negative" do
      let(:available_slots) { -1 }

      it { is_expected.not_to be_valid }
    end

    context "when the available slots is blank" do
      let(:available_slots) { "" }

      it { is_expected.not_to be_valid }
    end

    context "when the reserved slots is negative" do
      let(:reserved_slots) { -1 }

      it { is_expected.not_to be_valid }
    end

    context "when the reserved slots is blank" do
      let(:reserved_slots) { "" }

      it { is_expected.not_to be_valid }
    end

    context "when a few registrations have been created" do
      before do
        create_list :registration, 10, meeting:
      end

      context "and available slots is less than the number of registrations" do
        let(:available_slots) { 5 }

        it { is_expected.not_to be_valid }
      end

      context "and available slots is equal to 0 and not reserved slots" do
        let(:reserved_slots) { 0 }

        it { is_expected.to be_valid }
      end

      context "and available slots is equal to 0 and there are reserved slots" do
        it { is_expected.not_to be_valid }
      end
    end
  end
end
