# frozen_string_literal: true

module Decidim
  module Budgets
    module Focus
      class OrdersController < Decidim::Budgets::OrdersController
        before_action :set_focus_mode

        def status
          super

          render "decidim/budgets/orders/status"
        end

        protected

        def set_focus_mode
          @focus_mode = true
        end
      end
    end
  end
end
