# frozen_string_literal: true

module Decidim
  module Proposals
    module BaseProposalMetricTypeHelper
      extend ActiveSupport::Concern

      included do
        include Decidim::Core::BaseMetricTypeHelper
      end

      class_methods do
        def base_scope(_organization)
          Proposal
            .includes(:category)
            .published.not_hidden
        end
      end
    end
  end
end
