# frozen_string_literal: true

module Decidim
  module Admin
    # A form object used to impersonate managed users from the admin dashboard.
    #
    class ImpersonateManagedUserForm < Form
      def initialize(attributes)
        extend(Virtus.model)

        attribute(:authorization, attributes.dig(:authorization, :handler_name).classify.constantize)

        super
      end
    end
  end
end
