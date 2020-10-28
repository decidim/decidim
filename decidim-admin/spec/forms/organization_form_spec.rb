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

      let(:name) { "My super organization" }
      let(:reference_prefix) { "MSO" }
      let(:time_zone) { "UTC" }
      let(:twitter_handler) { "My twitter awesome handler" }
      let(:facebook_handler) { "My facebook awesome handler" }
      let(:instagram_handler) { "My instagram awesome handler" }
      let(:youtube_handler) { "My youtube awesome handler" }
      let(:github_handler) { "My github awesome handler" }
      let(:default_locale) { :en }
      let(:translation_priority) { "original" }
      let(:admin_terms_of_use_body) do
        {
          ca: "",
          en: "<p>Dummy admin terms body en</p>",
          es: ""
        }
      end
      let(:organization) { create(:organization) }
      let(:available_locales) { organization.available_locales }
      let(:attributes) do
        {
          "organization" => {
            "name" => name,
            "reference_prefix" => reference_prefix,
            "time_zone" => time_zone,
            "default_locale" => default_locale,
            "twitter_handler" => twitter_handler,
            "facebook_handler" => facebook_handler,
            "instagram_handler" => instagram_handler,
            "youtube_handler" => youtube_handler,
            "github_handler" => github_handler,
            "machine_translation_display_priority" => translation_priority,
            "admin_terms_of_use_body_ca" => admin_terms_of_use_body[:ca],
            "admin_terms_of_use_body_en" => admin_terms_of_use_body[:en],
            "admin_terms_of_use_body_es" => admin_terms_of_use_body[:es]
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

      context "when admin_terms_of_use_body is missing" do
        let(:admin_terms_of_use_body) do
          {
            ca: nil,
            en: nil,
            es: nil
          }
        end

        it { is_expected.to be_invalid }
      end

      context "when default language in admin_terms_of_use_body is missing" do
        let(:admin_terms_of_use_body) do
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
    end
  end
end
