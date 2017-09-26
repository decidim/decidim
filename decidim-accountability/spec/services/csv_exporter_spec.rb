# frozen_string_literal: true

require "spec_helper"

describe Decidim::Accountability::CSVExporter do
  let(:organization) { create(:organization) }
  let(:participatory_process) { create(:participatory_process, :with_steps, organization: organization) }
  let(:current_feature) { create :accountability_feature, participatory_space: participatory_process }
  let!(:scope) { create :scope, organization: organization }
  let!(:category) { create :category, participatory_space: participatory_process }
  let!(:status) { create :status, feature: current_feature, progress: 17 }
  let!(:result_1) { create :result,
    scope: scope,
    category: category,
    feature: current_feature,
    id: 1,
    external_id: "extid_1",
    start_date: Date.new(2017,6,10),
    end_date: Date.new(2017,9,30),
    status: status,
    progress: 25,
    title: { "ca" => "Title ca", "es" => "Title es", "en" => "Title en" },
    description: { "ca" => "Desc ca", "es" => "Desc es", "en" => "Desc en" }
  }
  let!(:result_2) { create :result,
    feature: current_feature,
    id: 2,
    external_id: "extid_2",
    start_date: Date.new(2017,8,16),
    end_date: Date.new(2017,10,20),
    status: status,
    progress: 29,
    title: { "ca" => "Title ca", "es" => "Title es", "en" => "Title en" },
    description: { "ca" => "Desc ca", "es" => "Desc es", "en" => "Desc en" }
  }
  let!(:proposal_feature) do
    create(:feature, manifest_name: "proposals", participatory_space: participatory_process)
  end
  let!(:proposals) do
    create_list(
      :proposal,
      3,
      feature: proposal_feature
    )
  end

  describe "export" do
    before(:each) do
      result_2.link_resources(proposals, "included_proposals")
    end

    it "exports feature results to CSV" do
      csv = Decidim::Accountability::CSVExporter.new(current_feature).export

      expected_csv = File.read(File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "exported.csv")))

      expect(csv).to eq(expected_csv)
    end
  end
end
