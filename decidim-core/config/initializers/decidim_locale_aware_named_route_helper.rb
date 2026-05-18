# frozen_string_literal: true

module Decidim
  module LocaleAwareNamedRouteHelper
    def call(_target, _method_name, _args, inner_options, _url_strategy)
      inner_options = inner_options&.symbolize_keys
      inner_options ||= {}

      inner_options = inner_options.merge(locale: I18n.locale) if @options[:locale].present? && !inner_options.has_key?(:locale)

      super
    end
  end
end

ActionDispatch::Routing::RouteSet::NamedRouteCollection::UrlHelper.prepend(Decidim::LocaleAwareNamedRouteHelper)
