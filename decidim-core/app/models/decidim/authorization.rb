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

    validates :name, uniqueness: { scope: :decidim_user_id }
    validates :verification_metadata, absence: true, if: :granted?
    validates :verification_attachment, absence: true, if: :granted?

    validate :active_handler?

    def grant!
      remove_verification_attachment!

      update!(granted_at: Time.zone.now, verification_metadata: {})
    end

    def granted?
      !granted_at.nil?
    end

    private

    def active_handler?
      if Decidim::Verifications.find_workflow_manifest(name)
        true
      else
        false
      end
    end
  end
end
