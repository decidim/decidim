# frozen_string_literal: true

module Decidim
  module Proposals
    # A form object to be used when public users want to create a collaborative
    # draft.
    class CollaborativeDraftWizardCreateStepForm < ProposalWizardCreateStepForm
      mimic :collaborative_draft
    end
  end
end
