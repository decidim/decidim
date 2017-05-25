# frozen_string_literal: true

require "decidim/proposals/admin"
require "decidim/proposals/engine"
require "decidim/proposals/admin_engine"
require "decidim/proposals/feature"

module Decidim
  # This namespace holds the logic of the `Proposals` component. This component
  # allows users to create proposals in a participatory process.
  module Proposals
    autoload :ProposalSerializer, "decidim/proposals/proposal_serializer"
  end
end
