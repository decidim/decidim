# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Assemblies
    # Common logic to ordering resources
    module Orderable
      extend ActiveSupport::Concern

      included do
        helper_method :order, :available_orders, :random_seed

        private

        # Gets how the proposals should be ordered based on the choice made by the user.
        def order
          @order ||= detect_order(params[:order]) || default_order
        end

        # Available orders based on enabled settings
        def available_orders
          @available_orders ||= %w(all government executive consultative_advisory participatory working_group commission others)
        end

        def default_order
          "all"
        end

        def detect_order(candidate)
          available_orders.detect { |order| order == candidate }
        end

        def reorder(assemblies)
          case order
          when "all"
            assemblies
          when "government"
            proposals
          when "recent"
            proposals.order(created_at: :desc)
          end
        end
      end
    end
  end
end
