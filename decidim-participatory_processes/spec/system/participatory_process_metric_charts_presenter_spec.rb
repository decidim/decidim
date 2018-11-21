# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ParticipatoryProcesses::MetricChartsPresenter do
    subject { described_class.new(participatory_process: process) }

    context "organization show_statistics attribute is true" do
      let(:participatory_process) {create(:participatory_process)}
      let(:organization) { create(:organization, show_statistics: true) }
      let(:assemblies) { create(:assemblies, show_statistics: true) }
      let(:comments) { create(:comments, show_statistics: true) }
      let(:results) { create(:comments, show_statistics: true) }
      let(:metrics) do
        Decidim.metrics_registry.filtered(highlight: true, scope: "participatory_process").each do |metric_registry|
          create(:metric, metric_type: metric_registry.metric_name, day: Time.zone.today - 1.week, organization: organization, participatory_space_type: Decidim::ParticipatoryProcess.name, participatory_space_id: participatory_process.id, cumulative: 5, quantity: 2)
        end
      end

      before do
        metrics
      end

      it "shows the metrics charts" do
        within "#metrics" do
          expect(page).to have_content(/Participation in figures/i)
          Decidim.metrics_registry.filtered(highlight: true, scope: "participatory_process").each do |metric_registry|
            expect(page).to have_css(%(##{metric_registry.metric_name}_chart))
          end
        end
      end

      # it "shows the small metrics charts" do
      #   safe_join(
      #     [:participatory_process, :assemblies, :comments, :results].map do |metric_key| # Temporal use of metrics to show charts
      #       render_metrics_data(Decidim.metrics_registry.for(metric_key).z, klass: "column medium-3", ratio: "16:9", margin: "margin-top: 30px", graph_klass: "small")
      #     end
      #   )
      # end
    end
  end
end
