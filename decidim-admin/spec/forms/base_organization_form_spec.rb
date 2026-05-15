# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe OrganizationForm do
      subject do
        described_class.from_params(attributes).with_context(
          context
        )
      end

      let(:name) { { ca: "", en: "My super organization", es: "" } }
      let(:description) do
        {
          en: "Description, awesome description",
          es: "Descripción",
          ca: "Descripció"
        }
      end
      let(:reference_prefix) { "MSO" }
      let(:time_zone) { "UTC" }
      let(:twitter_handler) { "My twitter awesome handler" }
      let(:facebook_handler) { "My facebook awesome handler" }
      let(:instagram_handler) { "My instagram awesome handler" }
      let(:youtube_handler) { "My youtube awesome handler" }
      let(:github_handler) { "My github awesome handler" }
      let(:default_locale) { :en }
      let(:translation_priority) { "original" }
      let(:comments_max_length) { 100 }
      let(:admin_terms_of_service_body) do
        {
          ca: "",
          en: "<p>Dummy admin terms body en</p>",
          es: ""
        }
      end
      let(:organization) { create(:organization) }
      let(:available_locales) { organization.available_locales }
      let(:empty_traslatable_attribute) do
        { en: "", es: "", ca: "" }
      end
      let(:enable_omnipresent_banner) { false }
      let(:omnipresent_banner_url) { nil }
      let(:omnipresent_banner_title) { empty_traslatable_attribute }
      let(:omnipresent_banner_short_description) { empty_traslatable_attribute }

      let(:attributes) do
        {
          "organization" => {
            "name" => name,
            "description_en" => description[:en],
            "description_es" => description[:es],
            "description_ca" => description[:ca],
            "reference_prefix" => reference_prefix,
            "time_zone" => time_zone,
            "default_locale" => default_locale,
            "twitter_handler" => twitter_handler,
            "facebook_handler" => facebook_handler,
            "instagram_handler" => instagram_handler,
            "youtube_handler" => youtube_handler,
            "github_handler" => github_handler,
            "comments_max_length" => comments_max_length,
            "machine_translation_display_priority" => translation_priority,
            "admin_terms_of_service_body_ca" => admin_terms_of_service_body[:ca],
            "admin_terms_of_service_body_en" => admin_terms_of_service_body[:en],
            "admin_terms_of_service_body_es" => admin_terms_of_service_body[:es],
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

      context "when name is missing" do
        let(:name) { nil }

        it { is_expected.to be_invalid }
      end

      context "when admin_terms_of_service_body is missing" do
        let(:admin_terms_of_service_body) do
          {
            ca: nil,
            en: nil,
            es: nil
          }
        end

        it { is_expected.to be_invalid }
      end

      context "when default language in admin_terms_of_service_body is missing" do
        let(:admin_terms_of_service_body) do
          {
            ca: "Termes i condicions de l'administrador (ca)"
          }
        end

        it { is_expected.to be_invalid }
      end

      context "when reference_prefix is missing" do
        let(:reference_prefix) { nil }

        it { is_expected.to be_invalid }
      end

      context "when time_zone is missing" do
        let(:time_zone) { nil }

        it { is_expected.to be_invalid }
      end

      context "when machine_translation_display_priority is a weird value and machine translations are active" do
        let(:translation_priority) { "foobar" }

        before do
          allow(Decidim.config).to receive(:enable_machine_translations).and_return(true)
        end

        it { is_expected.to be_invalid }
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
