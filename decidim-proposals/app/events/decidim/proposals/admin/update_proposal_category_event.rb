# frozen-string_literal: true

module Decidim
  module Proposals
    module Admin
      class UpdateProposalCategoryEvent < Decidim::Events::SimpleEvent
        include Decidim::Events::AuthorEvent
      end
    end
  end
end
