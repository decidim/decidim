# frozen_string_literal: true
require "active_support/concern"

module Decidim
  # A concern with the features needed when you want a model to be reportable
  module Reportable
    extend ActiveSupport::Concern

    included do
      has_many :reports, as: :reportable, foreign_key: "decidim_reportable_id", foreign_type: "decidim_reportable_type", class_name: "Decidim::Report"

      scope :reported,   -> { where("report_count > 0") }

      scope :not_hidden, -> { where(hidden_at: nil) }
      scope :hidden,     -> { where.not(hidden_at: nil) }

      # Public: Check if the user has reported the proposal.
      #
      # Returns Boolean.
      def reported_by?(user)
        reports.where(user: user).any?
      end

      # Public: Checks if the proposal is hidden or not.
      #
      # Returns Boolean.
      def hidden?
        hidden_at.present?
      end

      # Public: Checks if the proposal has been reported or not.
      #
      # Returns Boolean.
      def reported?
        report_count > 0
      end

      # Public: The reported content
      #
      # Returns html content
      def reported_content
      end
    end
  end
end
