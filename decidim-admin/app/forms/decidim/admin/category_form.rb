# frozen_string_literal: true
module Decidim
  module Admin
    # A form object used to create categories from the admin dashboard.
    #
    class CategoryForm < Form
      include TranslatableAttributes

      translatable_attribute :name, String
      translatable_attribute :description, String

      mimic :category

      validates :name, :description, translatable_presence: true
    end
  end
end
