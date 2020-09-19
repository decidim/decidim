# frozen_string_literal: true

module Decidim
  module Admin
    # A form object used to attach a component to a participatory process from the
    # admin panel.
    #
    class ComponentForm < Decidim::Form
      include TranslatableAttributes

      mimic :component

      translatable_attribute :name, String
      validates :name, translatable_presence: true

      attribute :weight, Integer, default: 0

      attribute :manifest, Object
      attribute :participatory_space, Object
      validates :manifest, :participatory_space, presence: true

      attribute :settings, Object
      attribute :default_step_settings, Object
      attribute :step_settings, Hash[String => Object]

      attribute :share_tokens, Array[ShareToken]

      def settings?
        settings.manifest.attributes.any?
      end

      def default_step_settings?
        default_step_settings.manifest.attributes.any?
      end

      def map_model(model)
        self.share_tokens = model.share_tokens
      end

      private

      # Overwrites Rectify::Form#form_attributes_valid? to validate nested `step_settings` attributes.
      def form_attributes_valid?
        return false unless errors.empty? && settings_errors_empty? # Preserves errors from custom validation methods

        attributes_that_respond_to(:valid?).concat(
          step_settings.each_value.select { |attribute| attribute.respond_to?(:valid?) }
        ).all?(&:valid?)
      end

      def settings_errors_empty?
        validations = [settings.errors.empty?]
        validations << if default_step_settings.present?
                         default_step_settings.errors.empty?
                       else
                         step_settings.each_value.map(&:errors).all?(&:empty?)
                       end
        validations.all?
      end
    end
  end
end
