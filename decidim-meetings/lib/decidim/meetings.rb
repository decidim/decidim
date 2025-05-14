# frozen_string_literal: true

require "decidim/meetings/admin"
require "decidim/meetings/api"
require "decidim/meetings/engine"
require "decidim/meetings/admin_engine"
require "decidim/meetings/directory"
require "decidim/meetings/directory_engine"
require "decidim/meetings/component"
require "decidim/meetings/polls"

module Decidim
  # Base module for this engine.
  module Meetings
    autoload :Registrations, "decidim/meetings/registrations"
    autoload :MeetingSerializer, "decidim/meetings/meeting_serializer"
    autoload :UserResponsesSerializer, "decidim/meetings/user_responses_serializer"
    autoload :SchemaOrgEventMeetingSerializer, "decidim/meetings/schema_org_event_meeting_serializer"

    include ActiveSupport::Configurable

    # Public Setting that defines whether proposals can be linked to meetings
    config_accessor :enable_proposal_linking do
      Decidim::Env.new("MEETINGS_ENABLE_PROPOSAL_LINKING", Decidim.const_defined?("Proposals")).present?
    end

    # Public Setting that defines the interval when the upcoming meeting will be sent
    config_accessor :upcoming_meeting_notification do
      Decidim::Env.new("MEETINGS_UPCOMING_MEETING_NOTIFICATION", 2).to_i.days
    end

    config_accessor :embeddable_services do
      Decidim::Env.new("MEETINGS_EMBEDDABLE_SERVICES", "www.youtube.com www.twitch.tv meet.jit.si").to_array(separator: " ")
    end

    config_accessor :waiting_list_enabled do
      Decidim::Env.new("MEETINGS_WAITING_LIST_ENABLED", true).present?
    end
  end

  module ContentParsers
    autoload :MeetingParser, "decidim/content_parsers/meeting_parser"
  end

  module ContentRenderers
    autoload :MeetingRenderer, "decidim/content_renderers/meeting_renderer"
  end
end
