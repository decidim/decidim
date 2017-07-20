# frozen_string_literal: true

module Decidim
  module Admin
    # A form object used to create managed users from the admin dashboard.
    #
    class ManagedUserForm < Form
      attribute :name, String

      validates :name, presence: true
      validates :authorization, presence: true

      def initialize(attributes)
        extend(Virtus.model)

        attribute(:authorization, attributes.dig(:authorization, :handler).constantize)

        super
      end
    end
  end
end
