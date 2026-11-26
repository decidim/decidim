# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::Import::ProposalsAnswersVerifier do
  subject { described_class.new(headers:, data: [], reader: Decidim::Admin::Import::Readers::CSV, context:) }

  let(:organization) { create(:organization, available_locales: [:en], default_locale: "en") }
  let(:context) { { current_organization: organization } }

  context "with the status header" do
    let(:headers) { %w(id status answer/en) }

    it { is_expected.to be_valid }
  end

  context "with the legacy state header" do
    let(:headers) { %w(id state answer/en) }

    it { is_expected.to be_valid }
  end

  context "without the status or state header" do
    let(:headers) { %w(id answer/en) }

    it "is invalid" do
      expect(subject).not_to be_valid
      expect(subject.errors[:headers].first).to include("status")
    end
  end

  context "without the answer header" do
    let(:headers) { %w(id state) }

    it "is invalid" do
      expect(subject).not_to be_valid
      expect(subject.errors[:headers].first).to include("answer/en")
    end
  end
end
