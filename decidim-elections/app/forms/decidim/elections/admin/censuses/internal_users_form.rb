# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      module Censuses
        class InternalUsersForm < Decidim::Form
          attribute :authorization_handlers, { String => Object }
          attribute :authorization_handlers_names, Array[String]
          attribute :authorization_handlers_options, { String => Object }

          validate :authorization_is_valid

          # Returns the settings that need to be persisted in the census.
          def census_settings
            {
              authorization_handlers: parsed_authorization_handlers
            }
          end

          def parsed_authorization_handlers
            authorization_handlers_names.filter_map do |name|
              next if name.blank?

              [
                name,
                { options: authorization_handler_options(name) }
              ]
            end.to_h
          end

          def authorization_handlers_names
            super.presence || authorization_handlers.keys.map(&:to_s)
          end

          def authorization_handler_options(handler_name)
            authorization_handlers_options&.dig(handler_name.to_s) || authorization_handlers&.dig(handler_name, "options").presence || {}
          end

          def manifest(handler_name)
            Decidim::Verifications.find_workflow_manifest(handler_name)
          end

          def options_schema(handler_name)
            options_manifest(handler_name).schema.new(authorization_handler_options(handler_name))
          end

          def options_attributes(handler_name)
            manifest = options_manifest(handler_name)
            manifest ? manifest.attributes : []
          end

          # Helper for the view, at this point, ephemeral authorizations are not supported in the elections module.
          def available_authorizations
            Decidim.authorization_workflows.filter do |workflow|
              current_organization.available_authorizations.include?(workflow.name) && !workflow.ephemeral?
            end
          end

          private

          def options_manifest(handler_name)
            manifest(handler_name).options
          end

          def authorization_is_valid
            return if authorization_handlers_names.blank?

            valid_types = context.current_organization.available_authorizations
            invalid_types = (authorization_handlers_names - valid_types).compact_blank

            errors.add(:base, :invalid) if invalid_types.present?
          end
        end
      end
    end
  end
end
