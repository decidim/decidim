# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Surveys
    describe ApplicationHelper do
      describe "#filter_surveys_date_values" do
        it "returns the correct filter values for survey dates" do
          expected_values = [
            ["all", I18n.t("all", scope: "decidim.surveys.surveys.filters")],
            ["open", { checked: true }, I18n.t("open", scope: "decidim.surveys.surveys.filters.state_values")],
            ["closed", I18n.t("closed", scope: "decidim.surveys.surveys.filters.state_values")]
          ]

          expect(helper.filter_surveys_date_values).to eq(expected_values)
        end
      end

      describe "#filter_sections" do
        it "returns the correct filter sections structure" do
          expected_sections = [{
            method: :with_any_state,
            collection: helper.filter_surveys_date_values,
            label: t("decidim.proposals.proposals.filters.state"),
            id: "state",
            type: :radio_buttons
          }]

          expect(helper.filter_sections).to eq(expected_sections)
        end
      end
    end
  end
end
