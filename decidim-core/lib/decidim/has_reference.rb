# frozen_string_literal: true
require "active_support/concern"

module Decidim
  # A concern with the features needed when you want a model to have a
  # reference.
  module HasReference
    extend ActiveSupport::Concern

    included do
      before_save :store_reference

      validates :reference, presence: true

      def reference
        self[:reference] || calculate_reference
      end

      private

      # Public: Calculates a unique reference for the model in
      # the following format:
      #
      # "BCN-DPP-2017-02-6589" which in this example translates to:
      #
      # BCN: A setting configured at the organization to be prepended to each reference.
      # PROP: Unique name identifier for a resource: Decidim::Proposals::Proposal (MEET for meetings or PROJ for projects).
      # 2017-02: Year-Month of the resource creation date
      # 6589: ID of the resource
      #
      # Returns a String.
      def calculate_reference
        return unless feature

        ref = feature.participatory_process.organization.reference_prefix
        class_identifier = self.class.name.demodulize[0..3].upcase
        year_month = (created_at || Time.current).strftime("%Y-%m")

        [ref, class_identifier, year_month, id].join("-")
      end

      # Internal: Sets the unique reference to the model.
      #
      # Returns nothing.
      def store_reference
        self[:reference] ||= calculate_reference
      end
    end
  end
end
