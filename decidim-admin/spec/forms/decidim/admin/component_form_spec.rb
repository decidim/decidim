# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe ComponentForm do
      subject { form }

      let(:organization) { create(:organization) }
      let(:participatory_space) { create(:participatory_process, organization: organization) }
      let(:manifest) { Decidim.find_component_manifest("dummy") }
      let(:name) { generate_localized_title }

      let(:default_registration_terms) do
        {
          "default_registration_terms_ca" => "",
          "default_registration_terms_en" => "Default terms en",
          "default_registration_terms_es" => ""

        }
      end

      let(:announcement) do
        {
          "announcement_ca" => "",
          "announcement_en" => "Default terms en",
          "announcement_es" => ""

        }
      end

      let(:settings) do
        return {} unless manifest

        manifest.settings(:global).schema.new(default_registration_terms, "en")
      end

      let(:default_step_settings) do
        return {} unless manifest

        manifest.settings(:step).schema.new(announcement, "en")
      end

      let(:params) do
        {
          "name" => name,
          "manifest" => manifest,
          "participatory_space" => participatory_space,
          "settings" => settings,
          "default_step_settings" => default_step_settings
        }
      end

      let(:form) do
        described_class.from_params(params).with_context(current_organization: organization)
      end

      context "when everything is ok" do
        it { is_expected.to be_valid }
      end

      context "when the name is missing" do
        let(:name) { nil }

        it { is_expected.not_to be_valid }
      end

      context "when the manifest is missing" do
        let(:manifest) { nil }

        it { is_expected.not_to be_valid }
      end

      context "when the participatory_space is missing" do
        let(:participatory_space) { nil }

        it { is_expected.not_to be_valid }
      end

      context "when a settings required attribute is missing" do
        let(:default_registration_terms) do
          {
            "default_registration_terms_ca" => "Default terms ca",
            "default_registration_terms_en" => "",
            "default_registration_terms_es" => "Default terms es"

          }
        end

        it { is_expected.not_to be_valid }
      end

      context "when a default_step_settings required attribute is missing" do
        let(:announcement) do
          {
            "announcement_ca" => "Default terms ca",
            "announcement_en" => "",
            "announcement_es" => "Default terms es"

          }
        end

        it { is_expected.not_to be_valid }
      end

      context "when the form has step_settings" do
        before do
          params.except("default_step_settings").merge(
            "step_settings" => { "1" => default_step_settings }
          )
        end

        context "and a step_settings required attribute is missing" do
          let(:announcement) do
            {
              "announcement_ca" => "Default terms ca",
              "announcement_en" => "",
              "announcement_es" => "Default terms es"

            }
          end

          it { is_expected.not_to be_valid }
        end
      end
    end
  end
end
