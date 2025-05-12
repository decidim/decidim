# frozen_string_literal: true

require "spec_helper"

module Decidim::Assemblies
  describe Decidim::StatisticsCell, type: :cell do
    controller Decidim::ApplicationController

    it_behaves_like "statistics cell" do
      let(:model) do
        [
          { stat_title: :participants_count, data: [123] },
          { stat_title: :participatory_space_proposals_count, data: [456, 50] }
        ]
      end
    end
  end
end
