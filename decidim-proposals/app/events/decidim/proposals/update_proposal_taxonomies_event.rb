# frozen_string_literal: true

module Decidim
  module Proposals
    class UpdateProposalTaxonomiesEvent < Decidim::Events::SimpleEvent
      include Decidim::Events::AuthorEvent
    end
  end
end
