# frozen_string_literal: true

module Decidim
  # This class holds common logic for diffing resources.
  # It is supposed to be a base class for all other diff renderers,
  # as it defines some helpful methods that later diff renderers can use.
  class BaseDiffRenderer
    include TranslatableAttributes

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

    # Private: Lists which attributes will be diffable and how they should be rendered.
    # This method must be overwritten by sub classes.
    #
    # Returns Hash.
    def attribute_types
      raise StandardError, "Not implemented"
    end

    def parse_i18n_changeset(attribute, values, type, diff)
      return diff unless values.last.is_a?(Hash)

      (values.last.keys - ["machine_translations"]).each do |locale, _value|
        first_value = values.first.try(:[], locale)
        last_value = values.last.try(:[], locale)
        next if first_value == last_value

        attribute_locale = :"#{attribute}_#{locale}"
        diff.update(
          attribute_locale => {
            type:,
            label: generate_i18n_label(attribute, locale),
            old_value: first_value,
            new_value: last_value
          }
        )
      end

      return diff unless values.last.has_key?("machine_translations")

      values.last.fetch("machine_translations").each_key do |locale, _value|
        next unless I18n.available_locales.include?(locale.to_sym)

        first_value = values.first.try(:[], "machine_translations").try(:[], locale)
        last_value = values.last.try(:[], "machine_translations").try(:[], locale)

        attribute_locale = :"#{attribute}_machine_translations_#{locale}"

        diff.update(
          attribute_locale => {
            type:,
            label: generate_i18n_label(attribute, locale, "decidim.machine_translations.automatic"),
            old_value: first_value,
            new_value: last_value
          }
        )
      end

      diff
    end

    def parse_user_group_changeset(attribute, values, type, diff)
      return unless diff

      old_user_group = Decidim::UserGroup.find_by(id: values[0])
      new_user_group = Decidim::UserGroup.find_by(id: values[1])

      diff.update(
        attribute => {
          type:,
          label: I18n.t(attribute, scope: i18n_scope),
          old_value: old_user_group ? translated_attribute(old_user_group.name) : "",
          new_value: new_user_group ? translated_attribute(new_user_group.name) : ""
        }
      )
    end

    def parse_scope_changeset(attribute, values, type, diff)
      return unless diff

      old_scope = Decidim::Scope.find_by(id: values[0])
      new_scope = Decidim::Scope.find_by(id: values[1])

      diff.update(
        attribute => {
          type:,
          label: I18n.t(attribute, scope: i18n_scope),
          old_value: old_scope ? translated_attribute(old_scope.name) : "",
          new_value: new_scope ? translated_attribute(new_scope.name) : ""
        }
      )
    end

    def parse_changeset(attribute, values, type, diff)
      return parse_i18n_changeset(attribute, values, type, diff) if [:i18n, :i18n_html].include?(type)

      return parse_scope_changeset(attribute, values, type, diff) if type == :scope
      return parse_user_group_changeset(attribute, values, type, diff) if type == :user_group

      diff.update(
        attribute => {
          type:,
          label: I18n.t(attribute, scope: i18n_scope),
          old_value: values[0],
          new_value: values[1]
        }
      )
    end

    # Returns a String.
    # i18n-tasks-use t("decidim.machine_translations.automatic")
    def generate_i18n_label(attribute, locale, postfix = "")
      label = I18n.t(attribute, scope: i18n_scope)
      locale_name = if I18n.available_locales.include?(locale.to_sym)
                      I18n.t("locale.name", locale:)
                    else
                      locale
                    end

      locale_name = I18n.t(postfix, locale_name:, locale:) if postfix.present?

      "#{label} (#{locale_name})"
    end

    # Returns a String.
    def i18n_scope
      model_name = version.item_type.constantize.model_name.singular_route_key
      "activemodel.attributes.#{model_name}"
    end
  end
end
