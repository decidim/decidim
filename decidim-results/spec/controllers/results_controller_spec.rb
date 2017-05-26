# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Results
    describe ResultsController, type: :controller do
      before do
        @request.env["decidim.current_organization"] = feature.organization
        @request.env["decidim.current_participatory_process"] = feature.participatory_process
        @request.env["decidim.current_feature"] = feature
      end

      describe "results" do
        let(:titles) { %w(Biure Atque Delectus Quia Fuga) }
        let(:feature) { create(:result_feature) }
        let(:results_count) { titles.size }

        it "returns a collection of results ordered by title" do
          Array.new(results_count) do |n|
            title = {}
            title[I18n.locale.to_s] = titles[n]
            create(:result, title: title, feature: feature)
          end

          results = controller.send(:results)
          expect(results.pluck(:title).map { |title| title[I18n.locale.to_s] }).to eq(titles.sort)
        end
      end
    end
  end
end
