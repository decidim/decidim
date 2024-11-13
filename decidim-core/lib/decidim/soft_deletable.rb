# frozen_string_literal: true

require "active_support/concern"
require "paranoia"

module Decidim
  # This concern contains the logic related to soft deletion (trashing).
  module SoftDeletable
    extend ActiveSupport::Concern

    included do
      acts_as_paranoid
      #
      # # Scope to return only records that have not been trashed (soft deleted).
      # scope :not_trashed, -> {
      #   ActiveSupport::Deprecation.warn("Using #{self.class.name}.not_trashed is deprecated. Use `#{self.class.name}.without_deleted` instead")
      #   without_deleted
      # }
      #
      # # Scope to return only trashed (soft deleted) records.
      # scope :trashed, -> {
      #   ActiveSupport::Deprecation.warn("Using #{self.class.name}.trashed is deprecated. Use `#{self.class.name}.only_deleted` instead")
      #   only_deleted
      # }

      scope :deleted_at_desc, -> { order(deleted_at: :desc) }
    end
    #
    # # Public: Checks whether the record has been trashed (soft deleted) or not.
    # #
    # # Returns true if trashed, false otherwise.
    # def trashed?
    #   ActiveSupport::Deprecation.warn("Using #{self.class.name}.trashed? is deprecated. Use `#{self.class.name}.deleted?` instead")
    #   deleted?
    # end
    #
    # # Public: Soft delete this record by setting `deleted_at`.
    # #
    # # Returns true if the record was properly saved, false otherwise.
    # def trash!
    #   ActiveSupport::Deprecation.warn("Using #{self.class.name}.trash! is deprecated. Use `#{self.class.name}.destroy` instead")
    #   destroy!
    # end
    #
    # # Public: Restore this record by clearing `deleted_at`.
    # #
    # # Returns true if the record was properly saved, false otherwise.
    # def restore!
    #   ActiveSupport::Deprecation.warn("Using #{self.class.name}.restore! is deprecated. Use `#{self.class.name}.restore` instead")
    #   restore
    # end
  end
end
