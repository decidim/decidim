# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/shared_examples/has_contextual_help"

describe "Participatory Processes", type: :system do
  let(:organization) { create(:organization) }
  let(:show_statistics) { true }
  let(:hashtag) { true }
  let(:base_process) do
    create(
      :participatory_process,
      organization: organization,
      description: { en: "Description", ca: "Descripció", es: "Descripción" },
      short_description: { en: "Short description", ca: "Descripció curta", es: "Descripción corta" },
      show_statistics: show_statistics
    )
  end

  context "when show all the metric charts" do
    let(:organization) { create(:organization, show_statistics: true) }
    let!(:participatory_process) { base_process }
    let(:metrics) do
      Decidim.metrics_registry.all.each do |metric_registry|
        create(:metric, metric_type: metric_registry.metric_name, day: Time.zone.today - 1.week, organization: organization, participatory_space_type: Decidim::ParticipatoryProcess.name, participatory_space_id: participatory_process.id, cumulative: 5, quantity: 2)
      end
    end

    before do
      switch_to_host(organization.host)
      metrics
      visit decidim_participatory_processes.statistics_participatory_process_path(participatory_process)
    end

    it "check if charts are present" do
      # BIG CHART
      big_stat = Decidim.metrics_registry.for(:users)
      expect(page).to have_css(%(##{big_stat.metric_name}_chart))
      check_title_and_description(big_stat.metric_name)
      # MEDIUM CHARTS
      [:proposals, :accepted_proposals, :votes, :meetings].each do |metric_key| # Temporal use of metrics to show charts
        expect(page).to have_css(%(##{Decidim.metrics_registry.for(metric_key).metric_name}_chart))
        check_title_and_description(Decidim.metrics_registry.for(metric_key).metric_name)
      end
      # LITTLE CHARTS
      [:participatory_processes, :assemblies, :comments, :results].each do |metric_key| # Temporal use of metrics to show charts
        expect(page).to have_css(%(##{Decidim.metrics_registry.for(metric_key).metric_name}_chart))
      end
    end

    def check_title_and_description(metric_name)
      find("div[id='#{metric_name}_chart']").find(:xpath, "../h3", count: 1)
      find("div[id='#{metric_name}_chart']").find(:xpath, "//p", count: 1)
    end
  end
end
