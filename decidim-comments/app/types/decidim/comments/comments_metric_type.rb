# frozen_string_literal: true

module Decidim
  module Comments
    CommentsMetricType = GraphQL::ObjectType.define do
      interfaces [-> { Decidim::Comments::CommentsMetricInterface }]

      name "CommentsMetricType"
      description "A Comment component of a participatory space."
    end

    module CommentsMetricTypeHelper
      def self.base_scope(organization, type = :count)
        Rails.cache.fetch("comments_metric/#{organization.try(:id)}/#{type}", expires_in: 24.hours) do
          Decidim::Comments::Metrics::CommentsMetricCount.for(organization, counter_type: type)
        end
      end
    end
  end
end
