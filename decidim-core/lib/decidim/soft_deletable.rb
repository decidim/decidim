# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # This concern handles the implementation of soft deletion for models.
  # It provides methods to mark records as deleted without actually removing them from the database,
  # and includes scopes to filter out or retrieve trashed records.
  module SoftDeletable
    extend ActiveSupport::Concern

    included do
      # NOTE: This is a temporary solution due to problems with migrations that use models
      # with a `deleted_at` column. The current approach checks the existence of the column
      # before defining the soft delete functionality. This should be refactored once
      # the migration issues are resolved to avoid using `column_names.include?`.
      @soft_deletable_available ||= column_names.include?("deleted_at")

      if @soft_deletable_available
        # Scope to return only non-deleted records.
        scope :not_deleted, -> { where(deleted_at: nil) }

        # Scope to return only trashed (soft deleted) records.
        scope :trashed, -> { where.not(deleted_at: nil) }
      else
        def self.trashed
          none
        end
      end
    end

    # Public: Checks whether the record has been trashed (soft deleted) or not.
    #
    # Returns true if trashed, false otherwise.
    def trashed?
      self.class.instance_variable_get(:@soft_deletable_available) && deleted_at.present?
    end

    # Public: Soft delete this record by setting `deleted_at`.
    #
    # Returns true if the record was properly saved, false otherwise.
    def trash!
      return false unless self.class.instance_variable_get(:@soft_deletable_available)

      update!(deleted_at: Time.current)
    end

    # Public: Restore this record by clearing `deleted_at`.
    #
    # Returns true if the record was properly saved, false otherwise.
    def restore!
      return false unless self.class.instance_variable_get(:@soft_deletable_available)

      update!(deleted_at: nil)
    end
  end
end
