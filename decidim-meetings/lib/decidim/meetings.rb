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

    class << self
      def config = self

      def configure
        yield self
      end
    end

    # Public Setting that defines the interval when the upcoming meeting will be sent
    mattr_accessor :upcoming_meeting_notification, default: Decidim::Env.new("MEETINGS_UPCOMING_MEETING_NOTIFICATION", 2).to_i.days

    mattr_accessor :embeddable_services, default: Decidim::Env.new("MEETINGS_EMBEDDABLE_SERVICES", "www.youtube.com www.twitch.tv meet.jit.si").to_array(separator: " ")

    mattr_accessor :waiting_list_enabled, default: Decidim::Env.new("MEETINGS_WAITING_LIST_ENABLED", true).present?
  end

  module ContentParsers
    autoload :MeetingParser, "decidim/content_parsers/meeting_parser"
  end

  module ContentRenderers
    autoload :MeetingRenderer, "decidim/content_renderers/meeting_renderer"
  end
end
