# frozen_string_literal: true

require "decidim/proposals/admin"
require "decidim/proposals/engine"
require "decidim/proposals/admin_engine"
require "decidim/proposals/component"

module Decidim
  # This namespace holds the logic of the `Proposals` component. This component
  # allows users to create proposals in a participatory process.
  module Proposals
    autoload :ProposalSerializer, "decidim/proposals/proposal_serializer"
    autoload :CommentableProposal, "decidim/proposals/commentable_proposal"

    include ActiveSupport::Configurable

    # Public Setting that defines the similarity minimum value to consider two
    # proposals similar. Defaults to 0.25.
    config_accessor :similarity_threshold do
      0.25
    end

    # Public Setting that defines how many similar proposals will be shown.
    # Defaults to 10.
    config_accessor :similarity_limit do
      10
    end
  end
end
