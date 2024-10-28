# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # This concern contains the logic related to soft deletion (trashing).
  module SoftDeletable
    extend ActiveSupport::Concern

    included do
      # Scope to return only records that have not been trashed (soft deleted).
      scope :not_trashed, -> { where(deleted_at: nil) }

      # Scope to return only trashed (soft deleted) records.
      scope :trashed, -> { where.not(deleted_at: nil) }

      scope :deleted_at_desc, -> { order(deleted_at: :desc) }
    end

    # Public: Checks whether the record has been trashed (soft deleted) or not.
    #
    # Returns true if trashed, false otherwise.
    def trashed?
      deleted_at.present?
    end

    # Public: Soft delete this record by setting `deleted_at`.
    #
    # Returns true if the record was properly saved, false otherwise.
    def trash!
      update!(deleted_at: Time.current)
    end

    # Public: Restore this record by clearing `deleted_at`.
    #
    # Returns true if the record was properly saved, false otherwise.
    def restore!
      update!(deleted_at: nil)
    end
  end
end
