# frozen_string_literal: true

module Decidim
  module Proposals
    module BaseProposalMetricTypeHelper
      extend ActiveSupport::Concern

      class_methods do
        def base_scope(_organization)
          # TODO: add organization scope
          Proposal
            .includes(:category)
            .published.not_hidden
        end
      end
    end
  end
end
