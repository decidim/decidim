# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe TaxonomyForm do
      subject { described_class.from_params(attributes).with_context(context) }

      let(:organization) { create(:organization) }
      let(:name) { { en: "Valid Name" } }
      let(:weight) { 1 }
      let(:parent_id) { nil }
      let(:attributes) do
        {
          name:,
          weight:,
          parent_id:
        }
      end

      let(:context) { { current_organization: organization } }

      context "when everything is OK" do
        it { is_expected.to be_valid }
      end

      context "when name is missing" do
        let(:name) { {} }

        it { is_expected.to be_invalid }
      end

      context "when weight is missing" do
        let(:weight) { nil }

        it { is_expected.to be_invalid }

        it "contains weight error" do
          subject.valid?
          expect(subject.errors[:weight]).not_to be_empty
        end
      end

      context "when weight is negative" do
        let!(:weight) { -1 }

        it { is_expected.to be_invalid }

        it "contains weight error" do
          subject.valid?
          expect(subject.errors[:weight]).not_to be_empty
        end
      end

      context "when parent_id is missing" do
        let(:parent_id) { nil }

        it { is_expected.to be_valid }
      end
    end
  end
end
