# frozen_string_literal: true

module Decidim
  # This class serializes a User so can be exported to CSV
  module Exporters
    class UserSerializer < Decidim::Exporters::Serializer
      include Decidim::ResourceHelper

      # Public: Initializes the serializer with a user.
      def initialize(user)
        @user = user
      end

      # Public: Exports a hash with the serialized data for this user.
      def serialize
        {
          id: @user.id,
          email: @user.email,
          name: @user.name,
          nickname: @user.nickname,
          locale: @user.locale,
          organization: @user.organization.try(:id),
          confirmed_at: @user.confirmed_at,
          newsletter_notifications: @user.newsletter_notifications,
          email_on_notification: @user.email_on_notification,
          admin: @user.admin,
          personal_url: @user.personal_url,
          about: @user.about,
          # user_groups: {
          #   @
          # }
        }
      end
      attr_reader :user
    end
  end
end
