# frozen_string_literal: true

module Decidim
  # This class serializes a User so can be exported to CSV
  module Exporters
    class DataPortabilityUserSerializer < Decidim::Exporters::Serializer
      include Decidim::ResourceHelper

      # Public: Exports a hash with the serialized data for this user.
      def serialize
        {
          id: resource.id,
          email: resource.email,
          name: resource.name,
          nickname: resource.nickname,
          locale: resource.locale,
          organization: resource.organization.try(:id),
          confirmed_at: resource.confirmed_at,
          newsletter_notifications: resource.newsletter_notifications,
          email_on_notification: resource.email_on_notification,
          admin: resource.admin,
          personal_url: resource.personal_url,
          about: resource.about,
          invited_by: {
            id: resource.invited_by_id,
            type: resource.invited_by_type
          },
          invitations_count: resource.invitations_count
        }
      end
    end
  end
end
