# frozen_string_literal: true

module Decidim
  # This class serializes a User so can be exported to CSV
  module DownloadYourDataSerializers
    class DownloadYourDataUserSerializer < Decidim::Exporters::Serializer
      include Decidim::ResourceHelper

      # Public: Exports a hash with the serialized data for this user.
      def serialize
        {
          id: resource.id,
          email: resource.email,
          name: resource.name,
          nickname: resource.nickname,
          locale: resource.locale,
          organization: {
            id: resource.organization.try(:id),
            name: resource.organization.try(:name)
          },
          newsletter_notifications_at: resource.newsletter_notifications_at,
          notifications_sending_frequency: resource.notifications_sending_frequency,
          admin: resource.admin,
          personal_url: resource.personal_url,
          about: resource.about,
          invitation_created_at: resource.invitation_created_at,
          invitation_sent_at: resource.invitation_sent_at,
          invitation_accepted_at: resource.invitation_accepted_at,
          invited_by: {
            id: resource.invited_by_id,
            type: resource.invited_by_type
          },
          invitations_count: resource.invitations_count,
          reset_password_sent_at: resource.reset_password_sent_at,
          remember_created_at: resource.remember_created_at,
          sign_in_count: resource.sign_in_count,
          current_sign_in_at: resource.current_sign_in_at,
          last_sign_in_at: resource.last_sign_in_at,
          current_sign_in_ip: resource.current_sign_in_ip,
          last_sign_in_ip: resource.last_sign_in_ip,
          created_at: resource.created_at,
          updated_at: resource.updated_at,
          confirmed_at: resource.confirmed_at,
          confirmation_sent_at: resource.confirmation_sent_at,
          unconfirmed_email: resource.unconfirmed_email,
          delete_reason: resource.delete_reason,
          deleted_at: resource.deleted_at,
          managed: resource.managed,
          officialized_at: resource.officialized_at,
          officialized_as: resource.officialized_as
        }
      end
    end
  end
end
