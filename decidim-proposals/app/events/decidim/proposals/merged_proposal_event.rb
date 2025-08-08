# frozen_string_literal: true

module Decidim
  module Proposals
    class MergedProposalEvent < Decidim::Events::SimpleEvent
      include Decidim::Events::AuthorEvent
    end
  end
end
