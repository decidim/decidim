# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # A form object to be used when admin users want to create a proposal.
      class ProposalForm < Admin::ProposalBaseForm
        validates :title, length: { in: 15..150 }
      end
    end
  end
end
