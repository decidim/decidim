# frozen_string_literal: true

module Decidim
  module DownloadYourDataSerializers
    autoload :DownloadYourDataUserSerializer, "decidim/download_your_data_serializers/download_your_data_user_serializer"
    autoload :DownloadYourDataUserGroupSerializer, "decidim/download_your_data_serializers/download_your_data_user_group_serializer"
    autoload :DownloadYourDataConversationSerializer, "decidim/download_your_data_serializers/download_your_data_conversation_serializer"
    autoload :DownloadYourDataReportSerializer, "decidim/download_your_data_serializers/download_your_data_report_serializer"
    autoload :DownloadYourDataFollowSerializer, "decidim/download_your_data_serializers/download_your_data_follow_serializer"
    autoload :DownloadYourDataNotificationSerializer, "decidim/download_your_data_serializers/download_your_data_notification_serializer"
    autoload :DownloadYourDataIdentitySerializer, "decidim/download_your_data_serializers/download_your_data_identity_serializer"
    autoload :DownloadYourDataParticipatorySpacePrivateUserSerializer, "decidim/download_your_data_serializers/download_your_data_participatory_space_private_user_serializer"

    def self.data_entities
      ["Decidim::Follow", "Decidim::Identity",
       "Decidim::Messaging::Conversation", "Decidim::Notification",
       "Decidim::ParticipatorySpacePrivateUser", "Decidim::Report", "Decidim::User", "Decidim::UserGroup"] |
        Decidim.component_manifests.map(&:data_portable_entities).flatten |
        Decidim.participatory_space_manifests.map(&:data_portable_entities).flatten |
        (Decidim::Comments.data_portable_entities.flatten if defined?(Decidim::Comments))
    end
  end
end
