# frozen_string_literal: true

require "spec_helper"

describe Decidim::Meetings::Admin::MeetingInscriptionsForm do
  let(:meeting) { create(:meeting) }
  let(:attributes) do
    {
      inscriptions_enabled: inscriptions_enabled,
      available_slots: available_slots,
      inscription_terms: inscription_terms
    }
  end
  let(:inscriptions_enabled) { true }
  let(:available_slots) { 10 }
  let(:inscription_terms) do
    {
      en: "A legal text",
      es: "Un texto legal",
      ca: "Un text legal"
    }
  end
  let(:context) { { current_organization: meeting.organization, meeting: meeting } }

  subject { described_class.from_params(attributes).with_context(context) }

  it { is_expected.to be_valid }

  context "when inscriptions are not enabled" do
    let(:inscriptions_enabled) { false }

    context "and the inscription terms are blank" do
      let(:inscription_terms) do
        {
          en: "",
          es: "",
          ca: ""
        }
      end

      it { is_expected.to be_valid }
    end
  end

  context "when inscriptions are enabled" do
    context "and the inscription terms are blank" do
      let(:inscription_terms) do
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

  context "when a few inscriptions have been created" do
    before do
      create_list :inscription, 10, meeting: meeting
    end

    context "and available slots is less than the number of inscriptions" do
      let(:available_slots) { 5 }
      it { is_expected.not_to be_valid }
    end

    context "and available slots is equal to 0" do
      it { is_expected.to be_valid }
    end
  end
end
