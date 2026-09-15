# frozen_string_literal: true

module Decidim
  module Api
    module Types
      class BaseMutation < GraphQL::Schema::RelayClassicMutation
        include Decidim::Api::GraphqlPermissions
        include Decidim::FormFactory

        object_class BaseObject
        field_class Types::BaseField
        input_object_class BaseInputObject

        required_scopes "api:read", "api:write"

        def handle_form_submission(form, &block)
          command = block.call

          result_record = nil

          command.on(:ok) do |result|
            # The result should be reloaded to reflect the associations
            result_record = result.reload
          end

          command.on(:invalid) do
            raise Decidim::Api::Errors::AttributeValidationError, form.errors
          end

          raise Decidim::Api::Errors::ValidationError, "Unexpected command result" if result_record.nil?

          result_record
        end

        def set_locale(locale:, toggle_translations:)
          raise I18n::InvalidLocale, "#{locale} is not a valid locale" unless available_locales.include?(locale)

          I18n.locale = locale.presence
          RequestStore.store[:toggle_machine_translations] = toggle_translations
        end

        def validate_multiple_locales(attributes, field)
          locales = (attributes.to_h.fetch(field, {}).presence || {}).keys.collect(&:to_s) - available_locales
          raise I18n::InvalidLocale, "#{locales.join(", ")} are not valid locales" if locales.size.positive?
        end

        def current_user
          context[:current_user]
        end

        def current_component
          context[:current_component]
        end

        def current_organization
          context[:current_organization]
        end

        def available_locales
          if current_organization.present?
            current_organization.available_locales
          else
            I18n.available_locales.map(&:to_s)
          end
        end
      end
    end
  end
end
