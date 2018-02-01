# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe OrganizationAppearanceForm do
      subject do
        described_class.from_params(attributes).with_context(
          context
        )
      end

      let(:header_snippets) { "<my-html />" }
      let(:welcome_text) do
        {
          en: "Welcome",
          es: "Hola",
          ca: "Hola"
        }
      end
      let(:description) do
        {
          en: "Description, awesome description",
          es: "Descripción",
          ca: "Descripció"
        }
      end
      let(:organization) { create(:organization) }
      let(:cta_button_path) { nil }
      let(:homepage_image_path) { Decidim::Dev.asset("city.jpeg") }
      let(:enable_omnipresent_banner) { false }
      let(:omnipresent_banner_url) { nil }
      let(:empty_traslatable_attribute) do
        { en: "", es: "", ca: "" }
      end
      let(:omnipresent_banner_title) { empty_traslatable_attribute }
      let(:omnipresent_banner_short_description) { empty_traslatable_attribute }
      let(:attributes) do
        {
          "organization_appearance" => {
            "welcome_text_en" => welcome_text[:en],
            "welcome_text_es" => welcome_text[:es],
            "welcome_text_ca" => welcome_text[:ca],
            "description_en" => description[:en],
            "description_es" => description[:es],
            "description_ca" => description[:ca],
            "homepage_image" => Rack::Test::UploadedFile.new(homepage_image_path, "image/jpeg"),
            "show_statics" => false,
            "cta_button_path" => cta_button_path,
            "header_snippets" => header_snippets,
            "enable_omnipresent_banner" => enable_omnipresent_banner,
            "omnipresent_banner_url" => omnipresent_banner_url,
            "omnipresent_banner_title_en" => omnipresent_banner_title[:en],
            "omnipresent_banner_title_es" => omnipresent_banner_title[:es],
            "omnipresent_banner_title_ca" => omnipresent_banner_title[:ca],
            "omnipresent_banner_short_description_en" => omnipresent_banner_short_description[:en],
            "omnipresent_banner_short_description_es" => omnipresent_banner_short_description[:es],
            "omnipresent_banner_short_description_ca" => omnipresent_banner_short_description[:ca]
          }
        }
      end
      let(:context) do
        {
          current_organization: organization,
          current_user: instance_double(Decidim::User).as_null_object
        }
      end

      context "when everything is OK" do
        it { is_expected.to be_valid }
      end

      context "when cta_button_path is a full URL" do
        let(:cta_button_path) { "http://example.org" }

        it { is_expected.not_to be_valid }
      end

      context "when cta_button_path is a valid path" do
        let(:cta_button_path) { "processes/my-process/" }

        it { is_expected.to be_valid }
      end

      context "when enable_omnipresent_banner is true" do
        let(:enable_omnipresent_banner) { true }
        let(:omnipresent_banner_url) { "http://www.example.org/random_url" }
        let(:omnipresent_banner_title) do
          { en: "title", es: "título", ca: "títol" }
        end
        let(:omnipresent_banner_short_description) do
          { en: "description", es: "descripción", ca: "descripció" }
        end

        it { is_expected.to be_valid }

        context "and omnipresent_banner_url is blank" do
          let(:omnipresent_banner_url) { nil }

          it { is_expected.not_to be_valid }
        end

        context "and omnipresent_banner_title is blank" do
          let(:omnipresent_banner_title) { empty_traslatable_attribute }

          it { is_expected.not_to be_valid }
        end

        context "and omnipresent_banner_short_description is blank" do
          let(:omnipresent_banner_short_description) { empty_traslatable_attribute }

          it { is_expected.not_to be_valid }
        end
      end
    end
  end
end
