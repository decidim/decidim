# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # A form object to be used when admin users want to review a collection of proposals
      # from a participatory text.
      class PreviewParticipatoryTextForm < Decidim::Form
        attribute :proposals, Array[ProposalForm]

        def from_models(proposals)
          self.proposals = proposals.collect do |proposal|
            ProposalForm.from_model(proposal)
          end
        end
      end
    end
  end
end
