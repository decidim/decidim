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
      let(:organization) { create(:organization) }
      let(:cta_button_path) { nil }
      let(:highlighted_content_banner_enabled) { false }
      let(:empty_translatable) { { en: "", es: "", ca: "" } }
      let(:highlighted_content_banner_title) { empty_translatable }
      let(:highlighted_content_banner_short_description) { empty_translatable }
      let(:highlighted_content_banner_action_title) { empty_translatable }
      let(:highlighted_content_banner_action_subtitle) { empty_translatable }
      let(:highlighted_content_banner_action_url) { nil }
      let(:highlighted_content_banner_image) { nil }
      let(:attributes) do
        {
          "organization" => {
            "show_statics" => false,
            "cta_button_path" => cta_button_path,
            "header_snippets" => header_snippets,
            "highlighted_content_banner_enabled" => highlighted_content_banner_enabled,
            "highlighted_content_banner_title_en" => highlighted_content_banner_title[:en],
            "highlighted_content_banner_title_es" => highlighted_content_banner_title[:es],
            "highlighted_content_banner_title_ca" => highlighted_content_banner_title[:ca],
            "highlighted_content_banner_short_description_en" => highlighted_content_banner_short_description[:en],
            "highlighted_content_banner_short_description_es" => highlighted_content_banner_short_description[:es],
            "highlighted_content_banner_short_description_ca" => highlighted_content_banner_short_description[:ca],
            "highlighted_content_banner_action_title_en" => highlighted_content_banner_action_title[:en],
            "highlighted_content_banner_action_title_es" => highlighted_content_banner_action_title[:es],
            "highlighted_content_banner_action_title_ca" => highlighted_content_banner_action_title[:ca],
            "highlighted_content_banner_action_subtitle_en" => highlighted_content_banner_action_subtitle[:en],
            "highlighted_content_banner_action_subtitle_es" => highlighted_content_banner_action_subtitle[:es],
            "highlighted_content_banner_action_subtitle_ca" => highlighted_content_banner_action_subtitle[:ca],
            "highlighted_content_banner_action_url" => highlighted_content_banner_action_url,
            "highlighted_content_banner_image" => highlighted_content_banner_image
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

      context "when highlighted_content_banner_enabled is true" do
        let(:highlighted_content_banner_enabled) { true }
        let(:highlighted_content_banner_title) { Decidim::Faker::Localized.sentence(word_count: 2) }
        let(:highlighted_content_banner_short_description) { Decidim::Faker::Localized.sentence(word_count: 2) }
        let(:highlighted_content_banner_action_title) { Decidim::Faker::Localized.sentence(word_count: 2) }
        let(:highlighted_content_banner_action_subtitle) { Decidim::Faker::Localized.sentence(word_count: 2) }
        let(:highlighted_content_banner_action_url) { ::Faker::Internet.url }
        let(:highlighted_content_banner_image) { upload_test_file(Decidim::Dev.test_file("city.jpeg", "image/jpeg")) }

        it { is_expected.to be_valid }

        context "and highlighted_content_banner_title is blank" do
          let(:highlighted_content_banner_title) { empty_translatable }

          it { is_expected.not_to be_valid }
        end

        context "and highlighted_content_banner_short_description is blank" do
          let(:highlighted_content_banner_short_description) { empty_translatable }

          it { is_expected.not_to be_valid }
        end

        context "and highlighted_content_banner_action_title is blank" do
          let(:highlighted_content_banner_action_title) { empty_translatable }

          it { is_expected.not_to be_valid }
        end

        context "and highlighted_content_banner_action_url is blank" do
          let(:highlighted_content_banner_action_url) { "" }

          it { is_expected.not_to be_valid }
        end

        context "and highlighted_content_banner_image is blank" do
          let(:highlighted_content_banner_image) { nil }

          it { is_expected.not_to be_valid }

          context "and the organization already has an image set" do
            let(:organization) { create(:organization, highlighted_content_banner_image: upload_test_file(Decidim::Dev.test_file("city.jpeg", "image/jpeg"))) }
            let(:highlighted_content_banner_image) { nil }

            it { is_expected.to be_valid }
          end
        end
      end

      context "when cta_button_path is a valid path with underscore" do
        let(:cta_button_path) { "processes/my_process/" }

        it { is_expected.to be_valid }
      end
    end
  end
end
