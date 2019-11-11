# frozen_string_literal: true

module Decidim
  module Proposals
    module AdminLog
      module ValueTypes
        class ProposalStatePresenter < Decidim::Log::ValueTypes::DefaultPresenter
          def present
            return unless value

            h.t(value, scope: "decidim.proposals.admin.proposal_answers.edit", default: value)
          end
        end
      end
    end
  end
end
