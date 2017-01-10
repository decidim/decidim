# frozen_string_literal: true
module Decidim
  module Admin
    # A form object used to attach a feature to a participatory process from the
    # admin panel.
    #
    class FeatureForm < Decidim::Form
      include TranslatableAttributes

      mimic :feature

      translatable_attribute :name, String
      validates :name, translatable_presence: true

      attribute :configuration, Object
      attribute :manifest

      def map_model(model)
        self.name = model.name

        self.configuration = configuration_schema.new(
          model.configuration.try(:[], "global")
        )
      end

      def configuration_schema
        manifest.configuration(:global).schema
      end
    end
  end
end
