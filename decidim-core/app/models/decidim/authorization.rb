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
    include Decidim::Traceable
    include Decidim::HasUploadValidations
    include Decidim::RecordEncryptor

    encrypt_attribute :metadata, type: :hash
    encrypt_attribute :verification_metadata, type: :hash

    has_one_attached :verification_attachment
    validates_upload :verification_attachment, uploader: Decidim::Verifications::AttachmentUploader

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
      update!(granted_at: Time.current, verification_metadata: {}, verification_attachment: nil)
    end

    def granted?
      !granted_at.nil?
    end

    # Returns true if the authorization is renewable by the participant
    def renewable?
      return unless workflow_manifest

      workflow_manifest.renewable && renewable_at < Time.current
    end

    # Returns a String, the cell to be used to render the metadata
    def metadata_cell
      return unless workflow_manifest

      workflow_manifest.metadata_cell
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

    # Transfers the authorization and data bound to the authorization to the
    # other user provided as an argument.
    #
    # @param hendler [Decidim::AuthorizationHandler] The authorization handler
    #   that caused the conflicting situation to happen and which stores the
    #   authorizing user's information with the latest authorization data.
    # @return [Decidim::AuthorizationTransfer] The authorization transfer that
    #   was just processed with its information.
    def transfer!(handler)
      Decidim::AuthorizationTransfer.perform!(self, handler)
    end

    private

    def active_handler?
      workflow_manifest.present?
    end

    def workflow_manifest
      @workflow_manifest ||= Decidim::Verifications.find_workflow_manifest(name)
    end

    # Calculates when this authorization can be reseted, if desired.
    #
    # **time_between_renewals** is defined in `workflow_manifest.time_between_renewals`
    # defaults to 1 day
    # Returns an ActiveSupport::TimeWithZone.
    def renewable_at
      (granted_at || created_at) + workflow_manifest.time_between_renewals
    end
  end
end
