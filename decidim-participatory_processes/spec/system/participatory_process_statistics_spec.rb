# frozen_string_literal: true

require "spec_helper"
require "csv"

describe "Participatory Processes", type: :system do
  let(:date) { Time.zone.today - 1.week }
  let(:organization) { create(:organization) }
  let(:show_statistics) { true }
  let(:participatory_process) do
    create(
      :participatory_process,
      organization: organization,
      show_statistics: show_statistics
    )
  end

  context "when show all the metric charts" do
    let(:metrics) do
      Decidim.metrics_registry.all.each do |metric_registry|
        create(:metric, metric_type: metric_registry.metric_name, day: date,
                        organization: organization, participatory_space_type: Decidim::ParticipatoryProcess.name,
                        participatory_space_id: participatory_process.id, cumulative: 5, quantity: 2)
      end
    end
    let(:key) { date.to_s }
    let(:value) { "5" }

    before do
      switch_to_host(organization.host)
      metrics
      visit decidim_participatory_processes.statistics_participatory_process_path(participatory_process)
    end

    it "check if charts are present" do
      # BIG CHART
      Decidim.metrics_registry.filtered(scope: "participatory_process", block: "big").each do |metric_manifest|
        expect(page).to have_css(%(##{metric_manifest.metric_name}_chart))
        check_title_and_description(metric_manifest.metric_name)
      end
      # MEDIUM CHARTS
      Decidim.metrics_registry.filtered(scope: "participatory_process", block: "medium").each do |metric_manifest|
        expect(page).to have_css(%(##{metric_manifest.metric_name}_chart))
        check_title_and_description(metric_manifest.metric_name)
      end
      # LITTLE CHARTS
      Decidim.metrics_registry.filtered(scope: "participatory_process", block: "small").each do |metric_manifest|
        expect(page).to have_css(%(##{metric_manifest.metric_name}_chart))
      end
    end

    def check_title_and_description(metric_name)
      find("div[id='#{metric_name}_chart']").find(:xpath, "../h3", class: "metric-title", count: 1, visible: :all)
      find("div[id='#{metric_name}_chart']").find(:xpath, "../p", class: "metric-description", count: 1, visible: :all)
    end
  end
end
