# frozen_string_literal: true
module Decidim
  module Proposals
    # Simple helpers to handle proposals ordering
    module ProposalOrderHelper
      # Returns the options the user will see to order proposals
      def order_fields
        @order_fields ||= begin
          order_fields = [:random, :recent]
          order_fields << :most_voted if current_settings.votes_enabled? && !current_settings.votes_hidden?
          order_fields
        end
      end
    end
  end
end
