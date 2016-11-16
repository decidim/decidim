# frozen_string_literal: true
require "spec_helper"

module Decidim
  module Admin
    describe OrganizationForm do
      let(:name) { "My super organization" }
      let(:description) do
        {
          en: "Description, awesome description",
          es: "Descripción",
          ca: "Descripció"
        }
      end
      let(:organization) { create(:organization) }
      let(:attributes) do
        {
          "organization" => {
            "name" => name,
            "description_en" => description[:en],
            "description_es" => description[:es],
            "description_ca" => description[:ca]
          }
        }
      end

      subject { described_class.from_params(attributes) }

      context "when everything is OK" do
        it { is_expected.to be_valid }
      end

      context "when name is missing" do
        let(:name) { nil }

        it { is_expected.to be_invalid }
      end

      context "when some language in description is missing" do
        let(:description) do
          {
            ca: "Descripció"
          }
        end

        it { is_expected.to be_invalid }
      end
    end
  end
end
