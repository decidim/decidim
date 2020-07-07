# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Meetings
    module Admin
      describe AutocompleteAddressHelper, type: :helper do
        describe "#autcomplete_address" do
          let(:options) do
            {
              placeholder: "Placeholder",
              help_text: "Help",
              label: "Label"
            }
          end

          let(:meeting) { create(:meeting) }
          let(:form) do
            Decidim::Admin::FormBuilder.new(
              :meeting,
              Decidim::Meetings::Admin::MeetingForm.new(meeting.attributes),
              view,
              {}
            )
          end

          let(:output) { helper.autocomplete_address(form, options) }
          let(:html) { Nokogiri::HTML(output) }
          let(:data) { JSON.parse(html.xpath("//div").first["data-autocomplete"], symbolize_names: true) }

          it "has the geocoder search url" do
            expect(data[:searchURL]).to eq("/api/geocoder")
          end

          it "has placeholder with value provided in options" do
            expect(data[:placeholder]).to eq "Placeholder"
          end

          it "has help text with value provided in options" do
            expect(html.xpath("//p[@class = 'help-text']").text).to eq("Help")
          end

          it "has label with value provided in options" do
            expect(html.xpath("//label").text).to match("Label")
          end
        end
      end
    end
  end
end
