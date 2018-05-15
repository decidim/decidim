# frozen_string_literal: true

module Decidim
  module Exporters
    autoload :Exporter, "decidim/exporters/exporter"
    autoload :JSON, "decidim/exporters/json"
    autoload :CSV, "decidim/exporters/csv"
    autoload :Excel, "decidim/exporters/excel"
    autoload :ExportData, "decidim/exporters/export_data"
    autoload :Serializer, "decidim/exporters/serializer"
    autoload :DataPortabilityUserSerializer, "decidim/exporters/data_portability_user_serializer"
    autoload :DataPortabilityUserGroupSerializer, "decidim/exporters/data_portability_user_group_serializer"
    autoload :DataPortabilityConversationSerializer, "decidim/exporters/data_portability_conversation_serializer"
    autoload :DataPortabilityReportSerializer, "decidim/exporters/data_portability_report_serializer"
    autoload :DataPortabilityFollowSerializer, "decidim/exporters/data_portability_follow_serializer"
    autoload :DataPortabilityNotificationSerializer, "decidim/exporters/data_portability_notification_serializer"
    autoload :DataPortabilityIdentitySerializer, "decidim/exporters/data_portability_identity_serializer"
    autoload :DataPortabilityParticipatorySpacePrivateUserSerializer, "decidim/exporters/data_portability_participatory_space_private_user_serializer"

    # Get the exporter class constant from the format as a string.
    #
    # format - The exporter format as a string. i.e "CSV"
    def self.find_exporter(format)
      const_get(format)
    end
  end
end
