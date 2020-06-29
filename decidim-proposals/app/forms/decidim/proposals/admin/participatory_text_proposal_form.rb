# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # A form object to be used when admin users want to create a proposal
      # through the participatory texts.
      class ParticipatoryTextProposalForm < Admin::ProposalBaseForm
        validates :title, length: { maximum: 150 }
      end
    end
  end
end
