# frozen_string_literal: true

module Decidim
  module Accountability
    # This class serializes a Result so can be exported to CSV, JSON or other
    # formats.
    class ResultSerializer < Decidim::Exporters::Serializer
      include Decidim::ResourceHelper
      include Decidim::TranslationsHelper

      # Public: Initializes the serializer with a result.
      def initialize(result)
        @result = result
      end

      # Public: Exports a hash with the serialized data for this result.
      def serialize
        {
          id: result.id,
          category: {
            id: result.category.try(:id),
            name: result.category.try(:name) || empty_translatable
          },
          scope: {
            id: result.scope.try(:id),
            name: result.scope.try(:name) || empty_translatable
          },
          parent: {
            id: result.parent.try(:id)
          },
          title: result.title,
          description: result.description,
          start_date: result.start_date,
          end_date: result.end_date,
          status: {
            id: result.status.try(:id),
            key: result.status.try(:key),
            name: result.status.try(:name) || empty_translatable
          },
          progress: result.progress,
          created_at: result.created_at,
          url:,
          component: { id: component.id },
          proposal_urls: proposals
        }
      end

      private

      attr_reader :result
      alias resource result

      def component
        result.component
      end

      def proposals
        result.linked_resources(:proposals, "included_proposals").map do |proposal|
          Decidim::ResourceLocatorPresenter.new(proposal).url
        end
      end

      def url
        Decidim::ResourceLocatorPresenter.new(result).url
      end
    end
  end
end
