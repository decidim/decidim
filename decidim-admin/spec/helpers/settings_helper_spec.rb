# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe SettingsHelper do
      let(:options) { {} }
      let(:attribute) { double(type: type, translated?: false, editor?: false) }
      let(:type) { :boolean }
      let(:name) { :test }

      let(:form) do
        double
      end

      def render_input
        helper.settings_attribute_input(form, attribute, name, options)
      end

      describe "booleans" do
        let(:type) { :boolean }

        it "is supported" do
          expect(form).to receive(:check_box).with(:test, options)
          render_input
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

        it "is supported" do
          expect(form).to receive(:text_area).with(:test, options)
          render_input
        end
      end

      describe "amendments_visibility_form_field" do
        let(:name) { :amendments_visibility }
        let(:collection_radio_buttons_arguments) do
          [
            :amendments_visibility,
            [["Amendments are visible to all", "all"], ["Amendments are visible only to their authors", "participants"]],
            :last,
            :first,
            { checked: "all" },
            { class: "amendments_step_settings" }
          ]
        end

        before do
          @component = create(:component, manifest_name: "proposals", step_settings: step_settings)
        end

        describe "when the component has step_settings" do
          let(:step_settings) { { "1": { amendments_visibility: "all" } } }

          it "is supported" do
            expect(form).to receive(:collection_radio_buttons).with(*collection_radio_buttons_arguments)
            render_input
          end
        end

        describe "when the component does NOT have step_settings" do
          let(:step_settings) { {} }

          it "is supported" do
            expect(form).to receive(:collection_radio_buttons).with(*collection_radio_buttons_arguments)
            render_input
          end
        end
      end
    end
  end
end
