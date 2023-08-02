# frozen_string_literal: true

require "spec_helper"

module Decidim::ParticipatoryProcesses
  describe Decidim::StatisticsCell, type: :cell do
    controller Decidim::ApplicationController

    it_behaves_like "statistics cell" do
      let(:model) do
        [
          { stat_title: :participants_count, stat_number: 123 },
          { stat_title: :proposals_count, stat_number: 456 },
          { stat_title: :comments_count, stat_number: 50 }
        ]
      end
    end
  end
end
