# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Demographics
    describe DemographicsForm do
      subject(:form) { described_class.from_params(attributes).with_context(context) }

      let(:organization) { create :organization }
      let(:context) do
        {
          current_organization: organization
        }
      end

      let(:gender) { ::Faker::Lorem.word }
      let(:nationalities) { ["Belgian"] }
      let(:age) { "24" }
      let(:postal_code) { "2425" }
      let(:attributes) do
        {
          "demographic" => {
            "gender" => gender,
            "age" => age,
            "nationalities" => nationalities,
            "postal_code" => postal_code,
            "background" => ""
          }
        }
      end

      context "when all the fields are correct" do
        it { is_expected.to be_valid }
      end

      describe "gender" do
        context "when is missing" do
          let(:gender) { nil }

          it { is_expected.to be_invalid }
        end
      end

      describe "age" do
        context "when is missing" do
          let(:age) { nil }

          it { is_expected.to be_invalid }
        end
      end

      describe "nationalities" do
        context "when is missing" do
          let(:nationalities) { [] }

          it { is_expected.to be_invalid }
        end
      end

      describe "postal_code" do
        context "when the format is not correct" do
          let(:postal_code) { "5f34" }

          it { is_expected.to be_invalid }
        end
      end
    end
  end
end
