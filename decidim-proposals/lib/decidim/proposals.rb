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
    autoload :CommentableCollaborativeDraft, "decidim/proposals/commentable_collaborative_draft"
    autoload :ViewModel, "decidim/proposals/view_model"

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

    # Public Setting that defines how many proposals will be shown in the
    # participatory_space_highlighted_elements view hook
    config_accessor :participatory_space_highlighted_proposals_limit do
      4
    end

    # Public Setting that defines how many proposals will be shown in the
    # process_group_highlighted_elements view hook
    config_accessor :process_group_highlighted_proposals_limit do
      3
    end
  end

  module ContentParsers
    autoload :ProposalParser, "decidim/content_parsers/proposal_parser"
  end

  module ContentRenderers
    autoload :ProposalRenderer, "decidim/content_renderers/proposal_renderer"
  end
end
