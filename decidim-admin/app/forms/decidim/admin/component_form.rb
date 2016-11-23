# frozen_string_literal: true
module Decidim
  module Admin
    # A form object used to create participatory processes from the admin
    # dashboard.
    #
    class ComponentForm < Decidim::Form
      include TranslatableAttributes

      mimic :component

      translatable_attribute :name, String
      attribute :step_id, Integer

      validates :name, translatable_presence: true
      validates :step_id, presence: true
    end
  end
end
