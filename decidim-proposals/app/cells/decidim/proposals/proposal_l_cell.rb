# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Proposals
    # This cell renders the List (:l) proposal card
    # for an instance of a Proposal
    class ProposalLCell < Decidim::CardLCell
      delegate :component_settings, to: :controller

      alias proposal model
    end
  end
end
