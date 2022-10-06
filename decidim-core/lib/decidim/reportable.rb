# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # A concern with the components needed when you want a model to be reportable
  module Reportable
    extend ActiveSupport::Concern

    included do
      has_one :moderation, as: :reportable, foreign_key: "decidim_reportable_id", foreign_type: "decidim_reportable_type", class_name: "Decidim::Moderation"
      has_many :reports, through: :moderation

      scope :reported, -> { left_outer_joins(:moderation).where(Decidim::Moderation.arel_table[:report_count].gt(0)) }
      scope :hidden, -> { left_outer_joins(:moderation).where.not(Decidim::Moderation.arel_table[:hidden_at].eq nil) }
      scope :not_hidden, -> { left_outer_joins(:moderation).where(Decidim::Moderation.arel_table[:hidden_at].eq nil) }

      # Public: Check if the user has reported the reportable.
      #
      # Returns Boolean.
      def reported_by?(user)
        reports.where(user:).any?
      end

      # Public: Checks if the reportable is hidden or not.
      #
      # Returns Boolean.
      def hidden?
        moderation&.hidden_at&.present? || false
      end

      # Public: Checks if the reportable has been reported or not.
      #
      # Returns Boolean.
      def reported?
        moderation&.report_count&.positive? || false
      end

      # Public: The reported content url
      #
      # Returns String
      def reported_content_url
        raise NotImplementedError
      end

      # Public: The collection of attribute names that are considered
      #         to be reportable.
      def reported_attributes
        raise NotImplementedError
      end

      # Public: An `Array` of `String` that will be concatenated to
      #         the reported searchable content. This content is used
      #         in the admin dashboard to filter moderations.
      def reported_searchable_content_extras
        []
      end

      # Public: The reported searchable content in a text format so
      #         moderations can be filtered by content.
      def reported_searchable_content_text
        reported_searchable_content_extras.concat(
          reported_attributes.map do |attribute_name|
            attribute_value = attributes.with_indifferent_access[attribute_name]
            next attribute_value.values.join("\n") if attribute_value.is_a? Hash

            attribute_value
          end
        ).join("\n")
      end
    end
  end
end
