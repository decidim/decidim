# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe DecidimFormHelper, type: :helper do
    describe "decidim_form_for" do
      it "injects custom options" do
        record = double("record").as_null_object

        options = {
          data: {
            abide: true,
            "live-validate" => true,
            "validate-on-blur" => true
          },
          html: {
            novalidate: true
          }
        }

        expect(helper).to receive(:form_for).with(record, options)

        helper.decidim_form_for(record) do
          "Foo"
        end
      end

      context "when there's errors on base" do
        it "adds an error callout" do
          form = Form.new
          form.errors.add(:base, "Arbitrary error")

          output = helper.decidim_form_for(form, url: "#") do
            # empty block
          end
          expect(output).to include("callout")
          expect(output).to include("Arbitrary error")
        end
      end
    end

    describe "translated_field_tag" do
      context "when a single locale is enabled" do
        before do
          allow(helper).to receive(:available_locales).and_return [:en]
        end

        it "renders the correct markup" do
          actual_markup = helper.translated_field_tag(
            :text_field_tag,
            "survey[questions][]",
            "body",
            { "en" => "My dummy body" },
            label: "Guacamole"
          )

          expected_markup = <<~HTML
            <label for="body">Guacamole</label>
            <input type="text" name="survey[questions][][body_en]" id="survey_questions__body_en" value="My dummy body" />
          HTML

          expect(expected_markup).to have_equivalent_markup_to(actual_markup)
        end
      end
    end

    describe "scopes_picker_field_tag" do
      let!(:scope) { create(:scope) }

      it "renders the correct markup" do
        actual = helper.scopes_picker_field_tag "my_thing[decidim_scope_id]", scope.id do
          { url: "/my/url", text: "My text" }
        end

        expected = <<~HTML
          <div id="my_thing_decidim_scope_id" class="data-picker picker-single" data-picker-name="my_thing[decidim_scope_id]">
            <div class="picker-values">
              <div><a href="/my/url" data-picker-value="#{scope.id}">My text</a></div>
            </div>

            <div class="picker-prompt"><a href="/my/url" role="button" aria-label="Select a scope (currently: My text)">My text</a></div>
          </div>
        HTML

        expect(actual).to have_equivalent_markup_to(expected)
      end
    end
  end
end
