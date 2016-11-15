# frozen_string_literal: true
module Decidim
  module Admin
    # A form object used to create participatory processes from the admin
    # dashboard.
    #
    class ComponentForm < Rectify::Form
      include TranslatableAttributes

      mimic :component

      translatable_attribute :name, String
      translatable_validates :name, presence: true

      attribute :component_type, String
      validates :component_type, presence: true
    end
  end
end
