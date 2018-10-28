# frozen_string_literal: true

module Decidim
  # A class with the responsibility to mapp fields between a Searchable and a SearchableResource.
  class SearchResourceFieldsMapper
    #
    # Declared fields may be of types:
    # - Hash for deep associations.
    # - Array each element should be a text field symbol, all values will be concatenated.
    # - Symbol when mapping is direct.
    #
    # @param declared_fields: A Hash with the mappings between a SearchableResource attributes and
    #    any given model. Mapped fields are:
    # - scope_id: The field where the scope is setted in the model, if any.
    # - participatory_space: The field where the ParticipatorySpace is setted in the model.
    # - datetime: The field that describes where in time the model is placed.
    # - A, B, C, D: Weighted text fields.
    #
    # Example value for declared_fields param:
    # {scope_id: :decidim_scope_id,
    # participatory_space: { component: :participatory_space },
    # A: :title,
    # D: [:description, :address],
    # datetime: :start_time}
    #
    def initialize(declared_fields)
      @declared_fields = declared_fields.with_indifferent_access
      @conditions = { create: true, update: true }
    end

    # @param action: currently supports :create, :update
    # @param condition: a boolean or a Proc that will receive the Searchable and will return a boolean.
    def set_index_condition(action, condition)
      @conditions[action] = condition
    end

    # Checks for the current searchable if it must be indexed when it is created or not.
    def index_on_create?(searchable)
      if @conditions[:create].is_a?(Proc)
        @conditions[:create].call(searchable)
      else
        @conditions[:create]
      end
    end

    # Checks for the current searchable if it must be indexed when it is updated or not.
    def index_on_update?(searchable)
      if @conditions[:update].is_a?(Proc)
        @conditions[:update].call(searchable)
      else
        @conditions[:update]
      end
    end

    def mapped(resource)
      fields = map_common_fields(resource)
      fields[:i18n] = map_i18n_fields(resource)
      fields
    end

    def retrieve_organization(resource)
      if @declared_fields[:organization_id].present?
        organization_id = read_field(resource, @declared_fields, :organization_id)
        Decidim::Organization.find(organization_id)
      else
        participatory_space(resource).organization
      end
    end

    private

    def participatory_space(resource)
      read_field(resource, @declared_fields, :participatory_space)
    end

    def map_common_fields(resource)
      participatory_space = participatory_space(resource)
      @organization = retrieve_organization(resource)
      {
        decidim_scope_id: read_field(resource, @declared_fields, :scope_id),
        decidim_participatory_space_id: participatory_space&.id,
        decidim_participatory_space_type: participatory_space&.class&.name,
        decidim_organization_id: @organization.id,
        datetime: read_field(resource, @declared_fields, :datetime)
      }
    end

    def read_field(resource, fields, field_name)
      if fields[field_name].is_a?(Hash)
        fields = fields[field_name]
        parent_field_name = fields.keys.first
        intermediate_model = resource.send(parent_field_name.to_sym)
        read_field(intermediate_model, fields, parent_field_name)
      else
        value_field = fields[field_name]
        return unless value_field

        if value_field.is_a?(Array)
          value_field.collect do |vfield_name|
            raise ArgumentError, "nested fields not supported for translations" if vfield_name.is_a?(Hash)
            resource.send(vfield_name.to_sym)
          end
        else
          value_field = value_field.to_sym
          resource.send(value_field) unless value_field.nil? || !resource.respond_to?(value_field)
        end
      end
    end

    def map_i18n_fields(resource)
      i18n = {}
      @organization.available_locales.each do |locale|
        content_a = read_i18n_field(resource, locale, :A)
        content_b = read_i18n_field(resource, locale, :B)
        content_c = read_i18n_field(resource, locale, :C)
        content_d = read_i18n_field(resource, locale, :D)
        i18n[locale] = { A: content_a, B: content_b, C: content_c, D: content_d }
      end
      i18n
    end

    def read_i18n_field(resource, locale, field_name)
      content = read_field(resource, @declared_fields, field_name)
      return if content.nil?
      content = Array.wrap(content).collect do |item|
        item.is_a?(Hash) ? item[locale] : item
      end
      content.respond_to?(:join) ? content.join(" ") : content
    end
  end
end
