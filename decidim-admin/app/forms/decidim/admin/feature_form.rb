# frozen_string_literal: true
module Decidim
  module Admin
    # A form object used to create participatory processes from the admin
    # dashboard.
    #
    class FeatureForm < Decidim::Form
      include TranslatableAttributes

      mimic :feature

      translatable_attribute :name, String
      translatable_validates :name, presence: true
    end
  end
end
