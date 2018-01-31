# frozen-string_literal: true

module Decidim
  module Proposals
    class AcceptedProposalEvent < Decidim::Events::SimpleEvent
      include Decidim::Events::AuthorEvent
    end
  end
end
