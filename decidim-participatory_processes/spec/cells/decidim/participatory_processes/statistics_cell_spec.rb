# frozen_string_literal: true

require "spec_helper"

module Decidim::ParticipatoryProcesses
  describe Statistics, type: :cell do
    controller Decidim::ApplicationController

    subject { cell("decidim/participatory_processes/statistics", model).call }

    let(:model) do
      [
        { stat_title: :participants_count, stat_number: 123 },
        { stat_title: :proposals_count, stat_number: 456 }
      ]
    end

    context "when rendering" do
      it "renders the statistics wrapper" do
        expect(subject).to have_css("#participatory_process-statistics")
      end

      it "renders the title" do
        expect(subject).to have_css("h3.section-heading", text: "Statistics")
      end

      it "renders each stat" do
        expect(subject).to have_css(".space-stats__data", count: 2)
      end
    end
  end
end
