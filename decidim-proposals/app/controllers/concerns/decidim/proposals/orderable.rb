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
            possible_orders << "most_endorsed" if current_settings.endorsements_enabled?
            possible_orders << "most_commented" if component_settings.comments_enabled?
            possible_orders << "most_followed" << "with_more_authors"
            possible_orders
          end
        end

        def default_order
          @default_order ||= fetch_default_order
        end

        def fetch_default_order
          default_order = current_settings.default_sort_order.presence || component_settings.default_sort_order
          return order_by_default if default_order == "default"

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

        def order_by_votes?
          most_voted_order_available? && current_settings.votes_blocked?
        end

        def reorder(proposals)
          case order
          when "most_commented"
            proposals.left_joins(:comments).group(:id).order(Arel.sql("COUNT(decidim_comments_comments.id) DESC"))
          when "most_endorsed"
            proposals.order(endorsements_count: :desc)
          when "most_followed"
            proposals.left_joins(:follows).group(:id).order(Arel.sql("COUNT(decidim_follows.id) DESC"))
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
