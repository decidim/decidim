# frozen_string_literal: true

require "spec_helper"

shared_examples "implements stats type" do
  context "when the space implements stats" do
    before do
      allow(Decidim::ParticipatoryProcesses::ParticipatoryProcessStatsPresenter).to receive(:new)
        .and_return(double(collection: [
                             { name: "dummies_count_high", data: [0], tooltip_key: "dummies_count_high_tooltip" },
                             { name: "pages_count", data: [0], tooltip_key: "pages_count_tooltip" },
                             { name: "proposals_count", data: [0], tooltip_key: "proposals_count_tooltip" },
                             { name: "meetings_count", data: [0], tooltip_key: "meetings_count_tooltip" },
                             { name: "projects_count", data: [0], tooltip_key: "budgets_count_tooltip" },
                             { name: "surveys_count", data: [0], tooltip_key: "surveys_count_tooltip" },
                             { name: "results_count", data: [0], tooltip_key: "results_count_tooltip" },
                             { name: "debates_count", data: [0], tooltip_key: "debates_count_tooltip" },
                             { name: "sortitions_count", data: [0], tooltip_key: "sortitions_count_tooltip" },
                             { name: "posts_count", data: [0], tooltip_key: "posts_count_tooltip" },
                             { name: "collaborative_texts_count", data: [0], tooltip_key: "collaborative_texts_count_tooltip" }
                           ]))
    end

    it "executes successfully" do
      expect { response }.not_to raise_error
    end

    it "returns the correct response" do
      expect(stats_response).to match_array(
        [
          { "name" => { "translation" => "Dummies high" }, "value" => 0 },
          { "name" => { "translation" => "Pages" }, "value" => 0 },
          { "name" => { "translation" => "Proposals" }, "value" => 0 },
          { "name" => { "translation" => "Meetings" }, "value" => 0 },
          { "name" => { "translation" => "Budgets" }, "value" => 0 },
          { "name" => { "translation" => "Surveys" }, "value" => 0 },
          { "name" => { "translation" => "Results" }, "value" => 0 },
          { "name" => { "translation" => "Debates" }, "value" => 0 },
          { "name" => { "translation" => "Sortitions" }, "value" => 0 },
          { "name" => { "translation" => "Posts" }, "value" => 0 },
          { "name" => { "translation" => "Collaborative texts" }, "value" => 0 }
        ]
      )
    end
  end
end
