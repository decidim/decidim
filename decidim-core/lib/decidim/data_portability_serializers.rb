# frozen_string_literal: true

module Decidim
  module DataPortabilitySerializers
    autoload :DataPortabilityUserSerializer, "decidim/data_portability_serializers/data_portability_user_serializer"
    autoload :DataPortabilityUserGroupSerializer, "decidim/data_portability_serializers/data_portability_user_group_serializer"
    autoload :DataPortabilityConversationSerializer, "decidim/data_portability_serializers/data_portability_conversation_serializer"
    autoload :DataPortabilityReportSerializer, "decidim/data_portability_serializers/data_portability_report_serializer"
    autoload :DataPortabilityFollowSerializer, "decidim/data_portability_serializers/data_portability_follow_serializer"
    autoload :DataPortabilityNotificationSerializer, "decidim/data_portability_serializers/data_portability_notification_serializer"
    autoload :DataPortabilityIdentitySerializer, "decidim/data_portability_serializers/data_portability_identity_serializer"
    autoload :DataPortabilityParticipatorySpacePrivateUserSerializer, "decidim/data_portability_serializers/data_portability_participatory_space_private_user_serializer"

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
