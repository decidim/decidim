# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Consultations
    describe ConsultationsHelper do
      describe "options_for_date_filter" do
        it "returns options for all available filters" do
          expect(helper.options_for_date_filter).to include(["all", t("consultations.filters.all", scope: "decidim")])
          expect(helper.options_for_date_filter).to include(["active", t("consultations.filters.active", scope: "decidim")])
          expect(helper.options_for_date_filter).to include(["upcoming", t("consultations.filters.upcoming", scope: "decidim")])
        end
      end
    end
  end
end
