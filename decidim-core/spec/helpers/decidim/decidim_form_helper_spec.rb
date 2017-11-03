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

          output = helper.decidim_form_for(form, url: "#") {}
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
            <label for="body">Guacamole</label><input type="text" name="survey[questions][][body_en]" id="survey_questions__body_en" value="My dummy body" />
          HTML

          expect(expected_markup.strip).to eq(actual_markup.strip)
        end
      end
    end
  end
end
