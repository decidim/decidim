# frozen_string_literal: true

require "decidim/elections/admin"
require "decidim/elections/trustee_zone"
require "decidim/elections/engine"
require "decidim/elections/admin_engine"
require "decidim/elections/trustee_zone_engine"
require "decidim/elections/component"
require "decidim/elections/jwk_utils"

module Decidim
  # This namespace holds the logic of the `Elections` component. This component
  # allows users to create elections in a participatory space.
  module Elections
    autoload :BulletinBoardClient, "decidim/elections/bulletin_board_client"
    autoload :AnswerSerializer, "decidim/elections/answer_serializer"

    def self.bulletin_board
      @bulletin_board ||= BulletinBoardClient.new(Rails.application.secrets.bulletin_board || {})
    end
  end
end
