# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe ScopeForm do
      subject { described_class.from_params(attributes).with_context(context) }

      let(:organization) { create :organization }
      let(:name) { Decidim::Faker::Localized.literal(::Faker::Address.unique.state) }
      let(:code) { ::Faker::Address.unique.state_abbr }
      let(:scope_type) { create :scope_type }
      let(:attributes) do
        {
          "scope" => {
            "name" => name,
            "code" => code,
            "scope_type" => scope_type
          }
        }
      end
      let(:context) do
        {
          "current_organization" => organization
        }
      end

      context "when everything is OK" do
        it { is_expected.to be_valid }
      end

      context "when name is missing" do
        let(:name) { {} }

        it { is_expected.to be_invalid }
      end

      context "when code is missing" do
        let(:code) { "" }

        it { is_expected.to be_invalid }
      end

      context "when code is not unique" do
        before do
          create(:scope, organization: organization, code: code)
        end

        it "is not valid" do
          expect(subject).not_to be_valid
          expect(subject.errors[:code]).not_to be_empty
        end
      end

      context "when the code exists in another organization" do
        before do
          create(:scope, code: code)
        end

        it { is_expected.to be_valid }
      end
    end
  end
end
