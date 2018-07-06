# frozen_string_literal: true

module Decidim
  module Core
    module BaseMetricTypeHelper
      extend ActiveSupport::Concern

      class_methods do
        def base_metric_scope(query, type = :count, attribute = :day)
          query = query.group(attribute) if type == :metric
          # group(:day).sum(:cumulative)

          query.count
        end
      end
    end
  end
end
