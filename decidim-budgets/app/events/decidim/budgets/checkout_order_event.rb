# frozen_string_literal: true

module Decidim
  module Budgets
    class CheckoutOrderEvent < Decidim::Events::SimpleEvent
      i18n_attributes :participatory_space_title

      def participatory_space_title
        @participatory_space_title ||= translated_attribute(resource.participatory_space.title)
      end
    end
  end
end
