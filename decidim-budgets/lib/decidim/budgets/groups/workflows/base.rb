# frozen_string_literal: true

module Decidim
  module Budgets
    module Groups
      module Workflows
        # This is the base Workflow class for Budgets Groups.
        class Base
          def initialize(budgets_group, user)
            @budgets_group = budgets_group
            @user = user
          end

          # Public: Decides if the given component should be highlighted.
          # This method must be overwritten for each Workflow class.
          # - component: the budgets component to consider
          #
          # Returns Boolean.
          def highlighted?(_component)
            raise StandardError, "Not implemented"
          end

          # Public: Decides if the given user should be allowed to vote in the given component.
          # This method must be overwritten for each Workflow class.
          # - component: the budgets component to consider
          # - consider_progress: should consider user orders in progress?
          #                      Using `false` allow UI to offer users to discard votes in progress to start voting in other component.
          #
          # Returns Boolean.
          def vote_allowed?(_component, _consider_progress = true)
            raise StandardError, "Not implemented"
          end

          attr_accessor :budgets_group, :user

          # Public: Return the list of budget components that are highlighted for the user.
          #
          # Returns Array.
          def highlighted
            @highlighted ||= budgets.select { |component| highlighted?(component) } .first
          end

          # Public: Return the list of budget components where the user is allowed to vote.
          #
          # Returns Array.
          def allowed
            @allowed ||= budgets.select { |component| vote_allowed?(component) }
          end

          # Public: Return the list of budget components where the user has voted.
          #
          # Returns Array.
          def voted
            @voted ||= orders.values.map { |order_info| order_info[:order].component if order_info[:status] == :voted } .compact
          end

          # Public: Return the list of budget components where the user has orders in progress.
          #
          # Returns Array.
          def progress
            @progress ||= orders.values.map { |order_info| order_info[:order].component if order_info[:status] == :progress } .compact
          end

          # Public: Return the list of budget components where the user could discard their order to vote in other components.
          #
          # Returns Array.
          def discardable
            progress
          end

          # Public: Return the status for the given budget component and the user
          # - component: the budgets component to consider
          #
          # Returns Boolean.
          def status(component)
            orders.dig(component.id, :status) || (vote_allowed?(component) ? :allowed : :not_allowed)
          end

          # Public: Return if the user can vote in the given budget component
          # - component: the budgets component to consider
          #
          # Returns Boolean.
          def voted?(component)
            orders.dig(component.id, :status) == :voted
          end

          # Public: Return if the user has a pending order in the given budget component
          # - component: the budgets component to consider
          #
          # Returns Boolean.
          def progress?(component)
            orders.dig(component.id, :status) == :progress
          end

          # Public: Return if the user has reached the voting limit on budgets
          #
          # Returns Boolean.
          def limit_reached?
            (allowed - progress).none?
          end

          # Public: Return all the budgets components that should be taken into account for the budgets group
          #
          # Returns an ActiveRecord::Relation.
          def budgets
            budgets_group.children.published
          end

          protected

          def orders
            @orders ||= Decidim::Budgets::Order.includes(:projects).where(decidim_user_id: user, decidim_component_id: budgets).map do |order|
              [order.decidim_component_id, { order: order, status: order.checked_out? ? :voted : :progress }] if order.projects.any?
            end.compact.to_h
          end
        end
      end
    end
  end
end
