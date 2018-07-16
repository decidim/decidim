# frozen_string_literal: true

module Decidim
  module Accountability
    class DiffRenderer
      def initialize(version)
        @version = version
      end

      # Renders the diff of the given changeset. Takes into account translatable fields.
      #
      # Returns a Hash, where keys are the fields that have changed and values are an
      # array, the first element being the previous value and the last being the new one.
      def diff
        version.changeset.inject({}) do |diff, (attribute, values)|
          attribute = attribute.to_sym
          type = attribute_types[attribute]

          if type.blank?
            diff
          else
            parse_changeset(attribute, values, type, diff)
          end
        end
      end

      private

      attr_reader :version

      # Lists which attributes will be diffable and how
      # they should be rendered.
      def attribute_types
        {
          start_date: :date,
          end_date: :date,
          description: :i18n_html,
          title: :i18n,
          decidim_scope_id: :scope,
          progress: :percentage
        }
      end

      def parse_i18n_changeset(attribute, values, type, diff)
        values.last.each_key do |locale, _value|
          first_value = values.first.try(:[], locale)
          last_value = values.last.try(:[], locale)
          next if first_value == last_value

          attribute_locale = "#{attribute}_#{locale}".to_sym
          diff.update(
            attribute_locale => {
              type: type,
              label: generate_i18n_label(attribute, locale),
              old_value: first_value,
              new_value: last_value
            }
          )
        end
        diff
      end

      def parse_changeset(attribute, values, type, diff)
        return parse_i18n_changeset(attribute, values, type, diff) if [:i18n, :i18n_html].include?(type)

        diff.update(
          attribute => {
            type: type,
            label: I18n.t(attribute, scope: "activemodel.attributes.result"),
            old_value: values[0],
            new_value: values[1]
          }
        )
      end

      def generate_i18n_label(attribute, locale)
        label = I18n.t(attribute, scope: "activemodel.attributes.result")
        locale_name = if I18n.available_locales.include?(locale.to_sym)
                        I18n.t("locale.name", locale: locale)
                      else
                        locale
                      end

        "#{label} (#{locale_name})"
      end
    end
  end
end
