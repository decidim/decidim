# frozen_string_literal: true

module Decidim
  module Budgets
    module Workflows
      # This is the base Workflow class.
      class Base
        def initialize(budgets_component, user)
          @budgets_component = budgets_component
          @user = user
        end

        # Public: Checks if the component has only one budget resource.
        #
        # Returns Boolean.
        def single?
          budgets.one?
        end

        # Public: Return the lonenly budget resource of the component
        #
        # Returns an ActiveRecord.
        def single
          budgets.first if single?
        end

        # Public: Decides if the given resource should be highlighted.
        # This method must be overwritten for each Workflow class.
        # - resource: the budget resource to consider
        #
        # Returns Boolean.
        def highlighted?(_resource)
          raise StandardError, "Not implemented"
        end

        # Public: Decides if the given user should be allowed to vote in the given resource.
        # This method must be overwritten for each Workflow class.
        # - resource: the budget resource to consider
        # - consider_progress: should consider user orders in progress?
        #                      Using `false` allow UI to offer users to discard votes in progress to start voting in another resource.
        #
        # Returns Boolean.
        def vote_allowed?(_resource, _consider_progress: true)
          raise StandardError, "Not implemented"
        end

        attr_accessor :budgets_component, :user

        # Public: Return the list of budget resources that are highlighted for the user.
        #
        # Returns Array.
        def highlighted
          @highlighted ||= budgets.select { |resource| highlighted?(resource) }
        end

        # Public: Return the list of budgets where the user is allowed to vote.
        #
        # Returns Array.
        def allowed
          @allowed ||= budgets.select { |resource| vote_allowed?(resource) }
        end

        # Public: Return the list of budget resources where the user has voted.
        #
        # Returns Array.
        def voted
          @voted ||= orders.values.map { |order_info| order_info[:order].budget if order_info[:status] == :voted }.compact
        end

        # Public: Return the list of budget resources where the user has orders in progress.
        #
        # Returns Array.
        def progress
          @progress ||= orders.values.map { |order_info| order_info[:order].budget if order_info[:status] == :progress }.compact
        end

        # Public: Return the list of budget resources where the user could discard their order to vote in other components.
        #
        # Returns Array.
        def discardable
          progress
        end

        # Public: Return the status for the given budget resource and the user
        # - resource: the budget resource to consider
        #
        # Returns Boolean.
        def status(resource)
          orders.dig(resource.id, :status) || (vote_allowed?(resource) ? :allowed : :not_allowed)
        end

        # Public: Return if the user can vote in the given budget resource
        # - resource: the budgets resource to consider
        #
        # Returns Boolean.
        def voted?(resource)
          orders.dig(resource.id, :status) == :voted
        end

        # Public: Return if the user has a pending order in the given budget resource
        # - resource: the budgets resource to consider
        #
        # Returns Boolean.
        def progress?(resource)
          orders.dig(resource.id, :status) == :progress
        end

        # Public: Return if the user has reached the voting limit on budgets
        #
        # Returns Boolean.
        def limit_reached?
          (allowed - progress).none?
        end

        # Public: Return all the budgets resources that should be taken into account for the budgets component
        #
        # Returns an ActiveRecord::Relation.
        def budgets
          @budgets ||= Decidim::Budgets::Budget.where(component: budgets_component).order(weight: :asc)
        end

        protected

        def orders
          @orders ||= Decidim::Budgets::Order.includes(:projects).where(decidim_user_id: user, decidim_budgets_budget_id: budgets).map do |order|
            [order.decidim_budgets_budget_id, { order:, status: order.checked_out? ? :voted : :progress }] if order.projects.any?
          end.compact.to_h
        end
      end
    end
  end
end
