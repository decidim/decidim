# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe DecidimFormHelper do
    describe "decidim_form_for" do
      it "injects custom options" do
        record = double("record").as_null_object

        options = {
          data: {
            controller: "form-validator autofocus",
            live_validate: true,
            validate_on_blur: true
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

      context "when there is errors on base" do
        it "adds an error callout" do
          form = Form.new
          form.errors.add(:base, "Arbitrary error")

          output = helper.decidim_form_for(form, url: "#") do
            # empty block
          end
          expect(output).to include("data-alert-box")
          expect(output).to include("Arbitrary error")
        end
      end
    end
  end
end
