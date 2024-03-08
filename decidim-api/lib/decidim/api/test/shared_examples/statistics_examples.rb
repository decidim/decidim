# frozen_string_literal: true

require "spec_helper"

shared_examples "implements stats type" do
  context "when the space implements stats" do
    let(:expected_data) do
      {
        "stats" => [
          { "name" => "dummies_count_high", "value" => 0 },
          { "name" => "pages_count", "value" => 0 },
          { "name" => "proposals_count", "value" => 0 },
          { "name" => "meetings_count", "value" => 0 },
          { "name" => "budgets_count", "value" => 0 },
          { "name" => "surveys_count", "value" => 0 },
          { "name" => "results_count", "value" => 0 },
          { "name" => "debates_count", "value" => 0 },
          { "name" => "sortitions_count", "value" => 0 },
          { "name" => "posts_count", "value" => 0 }
        ]
      }
    end

    it "executes successfully" do
      expect { response }.not_to raise_error
    end

    it "returns the correct response" do
      expect(stats_response).to match_array(expected_data["stats"])
    end
  end
end
