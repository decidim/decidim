# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # This concern contains the logic related to resource activation .
  module Activable
    extend ActiveSupport::Concern

    class_methods do
      # Public: Scope to return only activated records.
      #
      # Returns an ActiveRecord::Relation.
      def active
        where.not(activated_at: nil)
      end

      # Public: Scope to return only non-active records.
      #
      # Returns an ActiveRecord::Relation.
      def inactive
        where(activated_at: nil)
      end
    end

    # Public: Checks whether the record has been activated or not.
    #
    # Returns true if active, false otherwise.
    def active?
      activated_at.present?
    end

    #
    # Public: Activates this component
    #
    # Returns true if the record was properly saved, false otherwise.
    def activate!
      update!(activated_at: Time.current)
    end

    #
    # Public: Deactivates this component
    #
    # Returns true if the record was properly saved, false otherwise.
    def deactivate!
      update!(activated_at: nil)
    end
  end
end
