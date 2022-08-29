# frozen_string_literal: true

module Decidim
  module Budgets
    class OrderSummaryMailer < Decidim::ApplicationMailer
      include Decidim::TranslationsHelper
      include Decidim::SanitizeHelper

      helper Decidim::TranslationsHelper

      # Send an email to an user with the summary of the order.
      #
      # order - the order that was just created
      def order_summary(order)
        user = order.user

        with_user(user) do
          @user = user
          @order = order
          @budget = order.budget
          @space = order.budget.participatory_space
          @component = order.budget.component
          @organization = order.budget.participatory_space.organization

          subject = I18n.t(
            "order_summary.subject",
            scope: "decidim.budgets.order_summary_mailer",
            budget_name: translated_attribute(@budget.title),
            space_name: translated_attribute(@space.title)
          )
          mail(to: user.email, subject:)
        end
      end
    end
  end
end
