# frozen_string_literal: true

require "spec_helper"

module Decidim::Verifications::IdDocuments::Admin
  describe ConfigForm do
    subject { described_class.from_params(attributes).with_context(current_organization: organization) }

    let(:attributes) do
      {
        online:,
        offline:,
        offline_explanation:
      }
    end
    let(:organization) { create :organization }
    let(:online) { true }
    let(:offline) { false }
    let(:offline_explanation) { {} }

    context "when the information is valid" do
      it "is valid" do
        expect(subject).to be_valid
      end
    end

    context "when both modes are false" do
      let(:online) { false }
      let(:offline) { false }

      it "is not valid" do
        expect(subject).not_to be_valid
      end
    end

    context "when offline is true" do
      let(:offline) { true }

      it "is not valid without an explanation" do
        expect(subject).not_to be_valid
        expect(subject.errors[:offline_explanation_en])
          .to include("can't be blank")
      end
    end
  end
end
