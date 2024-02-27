# frozen-string_literal: true

module Decidim
  class ComponentPublishedEvent < Decidim::Events::SimpleEvent
    # Public: The Hash of options to pass to the I18.t method.
    def i18n_options
      default_i18n_options.merge(event_interpolations)
    end

    def resource_title
      return unless resource

      title = decidim_sanitize_translated(resource.name)
      Decidim::ContentProcessor.render_without_format(title, links: false).html_safe
    end
  end
end
