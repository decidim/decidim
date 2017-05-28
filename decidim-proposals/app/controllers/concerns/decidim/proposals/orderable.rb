# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Proposals
    # Common logic to ordering resources
    module Orderable
      extend ActiveSupport::Concern

      included do
        helper_method :order, :random_seed

        private

        # Gets how the proposals should be ordered based on the choice made by the user.
        def order
          @order ||= available_orders.detect { |order| order == params[:order] } || "random"
        end

        # Available orders based on enabled settings
        def available_orders
          if current_settings.votes_enabled? && current_settings.votes_hidden?
            %w(random recent)
          else
            %w(random recent most_voted)
          end
        end

        # Returns: A random float number between -1 and 1 to be used as a random seed at the database.
        def random_seed
          @random_seed ||= (params[:random_seed] ? params[:random_seed].to_f : (rand * 2 - 1))
        end

        def reorder(proposals)
          case order
          when "random"
            Proposal.transaction do
              Proposal.connection.execute("SELECT setseed(#{Proposal.connection.quote(random_seed)})")
              proposals.order("RANDOM()").load
            end
          when "most_voted"
            proposals.order(proposal_votes_count: :desc)
          when "recent"
            proposals.order(created_at: :desc)
          end
        end
      end
    end
  end
end
