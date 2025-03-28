# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    class IndicatorCell < Decidim::ViewModel
      include Decidim::Admin::IconWithTooltipHelper

      def show
        render
      end

      def metric_name
        options[:metric_name]
      end

      def metric_value
        number_with_precision(options[:metric_value], strip_insignificant_zeros: true, precision: 2)
      end

      def metric_tooltip
        options[:metric_tooltip]
      end
    end
  end
end
