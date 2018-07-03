# frozen_string_literal: true

module Decidim
  module Core
    module BaseMetricTypeHelper
      extend ActiveSupport::Concern

      class_methods do
        def base_metric_scope(query, attribute, type = :count)
          query = query.group("date_trunc('day', #{attribute})") if type == :metric
          query = query.count if [:count, :metric].include? type
          query
        end
      end
    end
  end
end
