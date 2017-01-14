# frozen_string_literal: true
require "spec_helper"

module Decidim
  module Admin
    describe ScopeForm do
      let(:name) { "my_name" }
      let(:organization) { create(:organization) }
      let(:attributes) do
        {
          "scope" => {
            "name" => name
          }
        }
      end
      let(:context) do
        {
          "current_organization" => organization,
        }
      end

      subject { described_class.from_params(attributes).with_context(context) }

      context "when everything is OK" do
        it { is_expected.to be_valid }
      end

      context "when name is missing" do
        let(:name) { nil }

        it { is_expected.to be_invalid }
      end

      context "when organization is missing" do
        let(:organization) { nil }

        it { is_expected.to be_invalid }
      end

      context "when slug is not unique" do
        before do
          create(:scope, organization: organization, name: name)
        end

        it "is not valid" do
          expect(subject).to_not be_valid
          expect(subject.errors[:name]).to_not be_empty
        end
      end

      context "when the slug exists in another organization" do
        before do
          create(:scope, name: name)
        end

        it { is_expected.to be_valid }
      end
    end
  end
end
