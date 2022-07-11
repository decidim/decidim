# frozen_string_literal: true

module Decidim
  # Represents an authorization transfer record, i.e. a Decidim record object
  # which was transferred from another user to the target user during an
  # authorization transfer.
  class AuthorizationTransferRecord < ApplicationRecord
    belongs_to :transfer, class_name: "Decidim::AuthorizationTransfer"
    belongs_to :resource, polymorphic: true

    # Overwrites the method so that records cannot be modified.
    #
    # @return [Boolean] a boolean indicating whether the record is read only.
    def readonly?
      !new_record?
    end

    # Returns the resource type for the records which is the value of the
    # resource_type column stored for the record or the mapped_resource_type for
    # the resource if it responds to that method.
    #
    # For example, Decidim::Coauthorable records need to report a model that
    # they represent instead of "Coauthorable" because otherwise e.g. proposal
    # transfers would not be reported correctly.
    #
    # @return [String] The resource type as string.
    def type
      resource.try(:mapped_resource_type) || resource_type
    end
  end
end
