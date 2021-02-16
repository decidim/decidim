# frozen_string_literal: true

require "decidim/elections/admin"
require "decidim/elections/api"
require "decidim/elections/trustee_zone"
require "decidim/elections/engine"
require "decidim/elections/admin_engine"
require "decidim/elections/trustee_zone_engine"
require "decidim/elections/component"
require "decidim/bulletin_board"
require "decidim/votings"

module Decidim
  # This namespace holds the logic of the `Elections` component. This component
  # allows users to create elections in a participatory space.
  module Elections
    autoload :AnswerSerializer, "decidim/elections/answer_serializer"

    include ActiveSupport::Configurable

    def self.bulletin_board
      @bulletin_board ||= Decidim::BulletinBoard::Client.new
    end

    # Public Setting that defines how many hours should the setup be run before the election starts
    config_accessor :setup_minimum_hours_before_start do
      3
    end

    # Public Setting that defines how many hours the ballot box can be opened before the election starts
    config_accessor :start_vote_maximum_hours_before_start do
      6
    end
  end
end
