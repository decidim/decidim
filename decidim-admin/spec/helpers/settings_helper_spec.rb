# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe SettingsHelper do
      let(:options) { { label: "A test", disabled: disabled } }
      let(:disabled) { false }
      let(:type) { :boolean }
      let(:name) { :test }
      let(:value) { nil }
      let(:i18n_scope) { "decidim.components.dummy.settings.global" }
      let(:form) { double(object: double(name => value)) }
      let(:choices) { [] }
      let(:attribute) do
        Decidim::SettingsManifest::Attribute.new(
          type: type,
          translated?: false,
          editor?: false,
          choices: choices
        )
      end

      def render_input
        helper.settings_attribute_input(form, attribute, name, i18n_scope, options)
      end

      describe "booleans" do
        let(:type) { :boolean }

        it "is supported" do
          expect(form).to receive(:check_box).with(:test, options)
          expect(render_input).not_to include("disabled_container")
        end

        context "when disabled" do
          let(:disabled) { true }

          it "is supported" do
            expect(form).to receive(:check_box).with(:test, options)
            expect(render_input).to include("disabled_container")
          end
        end
      end

      describe "numbers" do
        let(:type) { :integer }

        it "is supported" do
          expect(form).to receive(:number_field).with(:test, options)
          render_input
        end
      end

      describe "strings" do
        let(:type) { :string }

        it "is supported" do
          expect(form).to receive(:text_field).with(:test, options)
          render_input
        end
      end

      describe "texts" do
        let(:type) { :text }
        let(:extra_options) { options.merge(rows: 6) }

        it "is supported" do
          expect(form).to receive(:text_area).with(:test, extra_options)
          render_input
        end
      end

      describe "enums" do
        let(:type) { :enum }
        let(:value) { "a" }
        let(:full_choices) do
          [
            ["A choice", "a"],
            ["B choice", "b"],
            ["C choice", "c"]
          ]
        end

        let(:choices) { full_choices.map(&:last) }

        it "is supported" do
          expect(form).to receive(:collection_radio_buttons).with(
            :test,
            full_choices,
            :last,
            :first,
            { checked: "a" },
            options
          )
          render_input
        end

        context "when choices is a lambda function" do
          let(:choices) do
            -> { full_choices.map(&:last) }
          end

          it "is supported" do
            expect(form).to receive(:collection_radio_buttons).with(
              :test,
              full_choices,
              :last,
              :first,
              { checked: "a" },
              options
            )
            render_input
          end
        end
      end
    end
  end
end
