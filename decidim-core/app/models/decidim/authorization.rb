# frozen_string_literal: true

module Decidim
  # An authorization is a record that a User has been authorized somehow. Other
  # models in the system can use different kind of authorizations to allow a
  # user to perform actions.
  #
  # To create an authorization for a user we need to use an
  # AuthorizationHandler that validates the user against a set of rules. An
  # example could be a handler that validates a user email against an API and
  # depending on the response it allows the creation of the authorization or
  # not.
  class Authorization < ApplicationRecord
    mount_uploader :verification_attachment, Decidim::Verifications::AttachmentUploader

    belongs_to :user, foreign_key: "decidim_user_id", class_name: "Decidim::User"
    has_one :organization, through: :user, class_name: "Decidim::Organization"

    validates :name, uniqueness: { scope: :decidim_user_id }
    validates :verification_metadata, absence: true, if: :granted?
    validates :verification_attachment, absence: true, if: :granted?

    validate :active_handler?

    def self.create_or_update_from(handler)
      authorization = find_or_initialize_by(
        user: handler.user,
        name: handler.handler_name
      )

      authorization.attributes = {
        unique_id: handler.unique_id,
        metadata: handler.metadata
      }

      authorization.grant!
    end

    def grant!
      remove_verification_attachment!

      update!(granted_at: Time.current, verification_metadata: {})
    end

    def granted?
      !granted_at.nil?
    end

    # Calculates at when this authorization will expire, if it needs to.
    #
    # Returns nil if the authorization does not expire.
    # Returns an ActiveSupport::TimeWithZone if it expires.
    def expires_at
      return unless workflow_manifest
      return if workflow_manifest.expires_in.zero?
      (granted_at || created_at) + workflow_manifest.expires_in
    end

    def expired?
      expires_at.present? && expires_at < Time.current
    end

    private

    def active_handler?
      workflow_manifest.present?
    end

    def workflow_manifest
      @workflow_manifest ||= Decidim::Verifications.find_workflow_manifest(name)
    end
  end
end
