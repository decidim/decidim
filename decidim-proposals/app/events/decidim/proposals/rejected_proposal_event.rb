# frozen-string_literal: true

module Decidim
  module Proposals
    class RejectedProposalEvent < Decidim::Events::ExtendedEvent
      include Decidim::Events::AuthorEvent
    end
  end
end
