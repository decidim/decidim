# frozen_string_literal: true

module Decidim
  module Admin
    # A form object used to promote managed users from the admin dashboard.
    #
    class ManagedUserPromotionForm < Form
      attribute :email, String

      validates :email, presence: true
    end
  end
end
