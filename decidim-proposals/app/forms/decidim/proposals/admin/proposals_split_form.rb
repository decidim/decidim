# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # A form object to be used when admin users wants to split two or more
      # proposals into a new one to another proposal component in the same space.
      class ProposalsSplitForm < ProposalsForkForm
      end
    end
  end
end
