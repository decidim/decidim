# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe ComponentForm do
      subject { form }

      let(:organization) { create(:organization) }
      let(:participatory_space) { create(:participatory_process, organization:) }
      let(:manifest) { Decidim.find_component_manifest("dummy") }
      let(:name) { generate_localized_title }

      let(:dummy_global_translatable_text) do
        {
          "dummy_global_translatable_text_ca" => "",
          "dummy_global_translatable_text_en" => "Dummy text en",
          "dummy_global_translatable_text_es" => ""
        }
      end

      let(:dummy_step_translatable_text) do
        {
          "dummy_step_translatable_text_ca" => "",
          "dummy_step_translatable_text_en" => "Dummy text en",
          "dummy_step_translatable_text_es" => ""
        }
      end

      let(:settings) do
        return {} unless manifest

        manifest.settings(:global).schema.new(dummy_global_translatable_text, "en")
      end

      let(:default_step_settings) do
        return {} unless manifest

        manifest.settings(:step).schema.new(dummy_step_translatable_text, "en")
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
        let(:dummy_global_translatable_text) do
          {
            "dummy_global_translatable_text_ca" => "Dummy text ca",
            "dummy_global_translatable_text_en" => "",
            "dummy_global_translatable_text_es" => "Dummy text es"
          }
        end

        it { is_expected.not_to be_valid }
      end

      context "when a default_step_settings required attribute is missing" do
        let(:dummy_step_translatable_text) do
          {
            "dummy_step_translatable_text_ca" => "Dummy text ca",
            "dummy_step_translatable_text_en" => "",
            "dummy_step_translatable_text_es" => "Dummy text es"
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
          let(:dummy_step_translatable_text) do
            {
              "dummy_step_translatable_text_ca" => "Dummy text ca",
              "dummy_step_translatable_text_en" => "",
              "dummy_step_translatable_text_es" => "Dummy text es"
            }
          end

          it { is_expected.not_to be_valid }
        end
      end
    end
  end
end
