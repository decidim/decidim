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
            "default_locale" => :en,
            "available_locales" => %w{en ca es},
            "description_en" => description[:en],
            "description_es" => description[:es],
            "description_ca" => description[:ca]
          }
        }
      end
      let(:context) do
        {
          current_organization: organization,
          current_user: instance_double(Decidim::User).as_null_object
        }
      end

      subject { described_class.from_params(attributes, context) }

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

      context "when reducing the number of locales available" do
        let(:organization) { create(:organization, available_locales: %w{en ca es}) }
        let(:attributes) do
          {
            "organization" => {
              "name" => name,
              "default_locale" => :en,
              "available_locales" => %w{en ca},
              "description_en" => description[:en],
              "description_ca" => description[:ca]
            }
          }
        end

        it { is_expected.to be_valid }
      end

      context "when increasing the number of locales available" do
        let(:organization) { create(:organization, available_locales: %w{en ca}) }
        let(:attributes) do
          {
            "organization" => {
              "name" => name,
              "default_locale" => :en,
              "available_locales" => %w{en ca es},
              "description_en" => description[:en],
              "description_ca" => description[:ca]
            }
          }
        end

        it { is_expected.to be_valid }
      end
    end
  end
end
