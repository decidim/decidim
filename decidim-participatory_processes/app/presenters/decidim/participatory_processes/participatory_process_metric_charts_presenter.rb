# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # A presenter to render metrics in ParticipatoryProcesses statistics page
    class ParticipatoryProcessMetricChartsPresenter < Decidim::MetricChartsPresenter
      delegate :hidden_field_tag, :link_to, :capture, to: :view_context

      def participatory_process
        __getobj__.fetch(:participatory_process)
      end

      def params
        capture do
          concat(hidden_field_tag(:metrics_space_type, participatory_process.class.name, id: :"metrics-space_type"))
          concat(hidden_field_tag(:metrics_space_id, participatory_process.id, id: :"metrics-space_id"))
        end
      end
    end
  end
end
