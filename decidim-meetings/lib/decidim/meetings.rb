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
    autoload :UserAnswersSerializer, "decidim/meetings/user_answers_serializer"
    autoload :DownloadYourDataUserAnswersSerializer, "decidim/meetings/download_your_data_user_answers_serializer"

    include ActiveSupport::Configurable

    # Public Setting that defines whether proposals can be linked to meetings
    config_accessor :enable_proposal_linking do
      Decidim.const_defined?("Proposals")
    end

    # Public Setting that defines the interval when the upcoming meeting will be sent
    config_accessor :upcoming_meeting_notification do
      2.days
    end

    config_accessor :embeddable_services do
      %w(www.youtube.com www.twitch.tv meet.jit.si)
    end
  end

  module ContentParsers
    autoload :MeetingParser, "decidim/content_parsers/meeting_parser"
  end

  module ContentRenderers
    autoload :MeetingRenderer, "decidim/content_renderers/meeting_renderer"
  end
end
