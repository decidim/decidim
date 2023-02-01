# frozen_string_literal: true

require "spec_helper"

# REDESIGN_PENDING: This file is repeated in decidim-assemblies/spec/cells/decidim/assemblies/statistics_cell_spec.rb
# Both should be removed and merge in the core

module Decidim::ParticipatoryProcesses
  describe Decidim::StatisticsCell, type: :cell do
    controller Decidim::ApplicationController

    subject { cell("decidim/statistics", model).call }

    let(:model) do
      [
        { stat_title: :participants_count, stat_number: 123 },
        { stat_title: :proposals_count, stat_number: 456 },
        { stat_title: :comments_count, stat_number: 50 }
      ]
    end

    context "when rendering" do
      it "renders each stat" do
        expect(subject).to have_css("[data-statistic]", count: 3)
      end
    end
  end
end
