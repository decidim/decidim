# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Proposals
    # Common logic to ordering resources
    module Orderable
      extend ActiveSupport::Concern

      included do
        include Decidim::Orderable

        private

        # Available orders based on enabled settings
        def available_orders
          @available_orders ||= [default_order] + possible_orders.excluding(default_order)
        end

        def possible_orders
          @possible_orders ||= begin
            possible_orders = %w(random recent)
            possible_orders << "most_voted" if most_voted_order_available?
            possible_orders << "most_liked" if current_settings.likes_enabled?
            possible_orders << "most_commented" if most_commented_order_available?
            possible_orders << "most_followed"
            possible_orders << "with_more_authors" if with_more_authors_order_available?
            possible_orders
          end
        end

        def default_order
          @default_order ||= fetch_default_order
        end

        def fetch_default_order
          default_order = current_settings.default_sort_order.presence || component_settings.default_sort_order
          return order_by_default if default_order == "automatic"

          possible_orders.include?(default_order) ? default_order : order_by_default
        end

        def order_by_default
          if order_by_votes?
            "most_voted"
          else
            "random"
          end
        end

        def most_voted_order_available?
          current_settings.votes_enabled? && !current_settings.votes_hidden?
        end

        def with_more_authors_order_available?
          return @with_more_authors_order_available if defined?(@with_more_authors_order_available)

          @with_more_authors_order_available = Decidim::Proposals::Proposal.with_more_authors_available?(current_component)
        end

        def most_commented_order_available?
          return @most_commented_order_available if defined?(@most_commented_order_available)

          @most_commented_order_available = Decidim::Proposals::Proposal.most_commented_available?(current_component)
        end

        def order_by_votes?
          most_voted_order_available? && current_settings.votes_blocked?
        end

        def reorder(proposals)
          case order
          when "most_commented"
            proposals.order(comments_count: :desc)
          when "most_liked"
            proposals.order(likes_count: :desc)
          when "most_followed"
            proposals.order(follows_count: :desc)
          when "most_voted"
            proposals.order(proposal_votes_count: :desc)
          when "random"
            proposals.order_randomly(random_seed)
          when "recent"
            proposals.order(published_at: :desc)
          when "with_more_authors"
            proposals.order(coauthorships_count: :desc)
          end
        end
      end
    end
  end
end
