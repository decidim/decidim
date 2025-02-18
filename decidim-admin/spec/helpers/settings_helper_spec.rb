# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe SettingsHelper do
      let(:options) { { label: "A test", readonly: } }
      let(:readonly) { false }
      let(:type) { :boolean }
      let(:name) { :test }
      let(:value) { nil }
      let(:i18n_scope) { "decidim.components.dummy.settings.global" }
      let(:form) { double(object: double(name => value), object_name: name) }
      let(:choices) { [] }
      let(:attribute) do
        Decidim::SettingsManifest::Attribute.new(
          type:,
          translated?: false,
          editor?: false,
          choices:
        )
      end
      let(:organization) { create(:organization) }

      let(:current_participatory_space) { create(:participatory_process, organization:) }
      let(:component) { create(:dummy_component, participatory_space: current_participatory_space) }

      before do
        allow(view).to receive(:current_participatory_space).and_return(current_participatory_space)
        allow(view).to receive(:current_organization).and_return(organization)
        allow(view).to receive(:current_participatory_space_manifest).and_return(current_participatory_space.manifest)
        allow(view).to receive(:decidim_sanitize_translated).and_return("A text")
        view.instance_variable_set(:@component, component)
        allow(nil).to receive(:html_safe).and_return("")
      end

      def render_input
        helper.settings_attribute_input(form, attribute, name, i18n_scope, options)
      end

      describe "select" do
        let(:type) { :select }
        let(:choices) { %w(foo bar baz) }
        let(:full_choices) do
          [
            %w(Foo foo),
            %w(Bar bar),
            %w(Baz baz)
          ]
        end
        let(:options) { { include_blank: false, label: "A test" } }

        it "is supported" do
          expect(form).to receive(:select).with(
            :test,
            full_choices,
            options
          )
          render_input
        end
      end

      describe "booleans" do
        let(:type) { :boolean }

        it "is supported" do
          expect(form).to receive(:check_box).with(:test, options)
          expect(render_input).not_to include("readonly_container")
        end

        context "when readonly" do
          let(:readonly) { true }

          it "is supported" do
            expect(form).to receive(:check_box).with(:test, options)
            expect(render_input).to include("readonly_container")
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

      describe "float" do
        let(:type) { :float }

        it "is supported" do
          expect(form).to receive(:number_field).with(:test, options)
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

      describe "times" do
        let(:type) { :time }

        it "is supported" do
          expect(form).to receive(:datetime_field).with(:test, options)
          render_input
        end
      end

      describe "taxonomy_filters" do
        let(:type) { :taxonomy_filters }
        let!(:taxonomy1) { create(:taxonomy, :with_parent, organization:) }
        let!(:taxonomy2) { create(:taxonomy, :with_parent, organization:) }
        let!(:taxonomy_filter1) { create(:taxonomy_filter, root_taxonomy: taxonomy1.parent) }
        let!(:taxonomy_filter2) { create(:taxonomy_filter, root_taxonomy: taxonomy2.parent) }
        let(:choices) { [["A text (0)", taxonomy_filter1.id], ["A text (0)", taxonomy_filter2.id]] }
        let(:options) { { include_blank: "Select a taxonomy filter" } }
        let(:value) { [taxonomy_filter1.id] }

        before do
          component.update!(settings: { taxonomy_filters: [taxonomy_filter1.id] })
        end

        it "is supported" do
          expect(view).to receive(:render).with(partial: "decidim/admin/taxonomy_filters_selector/component_table", locals: { field_name: "test[test][]", component: })
          expect(view).to receive(:render).with(partial: "decidim/admin/components/taxonomy_filters_drawer")
          render_input
        end
      end

      describe "help texts" do
        let(:form) { Decidim::Admin::FormBuilder.new(:foo, double(name => value), template, {}) }
        let(:template) { Class.new(ActionView::Base).new(ActionView::LookupContext.new(ActionController::Base.view_paths), {}, []) }
        let(:type) { :boolean }
        let(:name) { :guided }

        it "renders the help text" do
          expect(render_input).to include(%(<span class="help-text">Help text</span>))
        end

        context "with HTML enriched help text" do
          let(:name) { :guided_rich }

          it "renders the HTML formatted help text" do
            expect(render_input).to include(%(<span class="help-text">HTML <strong>help</strong> text</span>))
          end
        end
      end

      describe "#text_for_setting" do
        let(:name) { :guided }

        context "with inexistent suffix" do
          let(:suffix) { :inexistent }

          it "does not render anything" do
            expect(helper.send(:text_for_setting, name, suffix, i18n_scope)).to be_nil
          end
        end

        context "with readonly" do
          let(:suffix) { "readonly" }

          it "renders the text" do
            expect(helper.send(:text_for_setting, name, suffix, i18n_scope)).to eq("Disabled input")
          end

          context "with HTML enriched text" do
            let(:name) { :guided_rich }

            it "renders the HTML formatted text" do
              expect(helper.send(:text_for_setting, name, suffix, i18n_scope)).to eq("HTML <strong>help</strong> text for disabled input")
            end
          end
        end

        context "with help" do
          let(:suffix) { "help" }

          it "renders the text" do
            expect(helper.send(:text_for_setting, name, suffix, i18n_scope)).to eq("Help text")
          end

          context "with HTML enriched text" do
            let(:name) { :guided_rich }

            it "renders the HTML formatted text" do
              expect(helper.send(:text_for_setting, name, suffix, i18n_scope)).to eq("HTML <strong>help</strong> text")
            end
          end
        end
      end
    end
  end
end
