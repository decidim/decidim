# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # A concern with the features needed when you want a model to be reportable
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
        reports.where(user: user).any?
      end

      # Public: Checks if the reportable is hidden or not.
      #
      # Returns Boolean.
      def hidden?
        moderation&.hidden_at&.present?
      end

      # Public: Checks if the reportable has been reported or not.
      #
      # Returns Boolean.
      def reported?
        moderation&.report_count&.positive?
      end

      # Public: The reported content url
      #
      # Returns String
      def reported_content_url
        raise NotImplementedError
      end
    end
  end
end
