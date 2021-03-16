# frozen_string_literal: true

require "decidim/votings/admin"
require "decidim/votings/api"
require "decidim/votings/polling_officer_zone"
require "decidim/votings/census_admin"
require "decidim/votings/census"
require "decidim/votings/engine"
require "decidim/votings/admin_engine"
require "decidim/votings/polling_officer_zone_engine"
require "decidim/votings/participatory_space"
require "decidim/votings/census_engine"
require "decidim/votings/census_admin_engine"

module Decidim
  # This namespace holds the logic of the `Votings` space.
  module Votings
    autoload :VotingSerializer, "decidim/votings/voting_serializer"
  end
end
