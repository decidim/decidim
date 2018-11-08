# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # A form object to be used when admin users wants to merge two or more
      # proposals into a new one to another proposal component in the same space.
      class ProposalsMergeForm < ProposalsForkForm
        validates :proposals, length: { minimum: 2 }
      end
    end
  end
end
