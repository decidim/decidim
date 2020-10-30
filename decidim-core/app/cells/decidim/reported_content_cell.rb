# frozen_string_literal: true

module Decidim
  # This cell renders a specific cells for the resource if it was configured
  # in the component's manifest or a default cell.
  class ReportedContentCell < Decidim::ViewModel
    def show
      if resource_cell?
        cell(resource_cell, model, options)
      else
        render :show
      end
    end

    private

    def render_value(value)
      content = I18n.with_locale(options.fetch(:locale, I18n.locale)) do
        if value.is_a? Hash
          translated_attribute(value)
        else
          value
        end
      end
      simple_format(content, sanitize: true)
    end

    def resource_cell?
      resource_cell.present?
    end

    def resource_cell
      @resource_cell ||= resource_reported_content
    end

    def resource_reported_content
      resource_manifest&.reported_content_cell.presence
    end

    def resource_manifest
      model.try(:resource_manifest) || Decidim.find_resource_manifest(model.class)
    end
  end
end
