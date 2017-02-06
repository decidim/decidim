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
          }
        }

        expect(helper).to receive(:form_for).with(record, options)

        helper.decidim_form_for(record) do
          "Foo"
        end
      end
    end
  end
end
