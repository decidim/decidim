# frozen_string_literal: true

module Decidim
  module LocaleAwareNamedRouteHelper
    def call(t, method_name, args, inner_options, url_strategy)
      inner_options = inner_options&.symbolize_keys
      inner_options ||= {}

      if @options[:locale].present? && !inner_options.key?(:locale)
        inner_options = inner_options.merge(locale: I18n.locale)
      end

      super(t, method_name, args, inner_options, url_strategy)
    end
  end
end

ActionDispatch::Routing::RouteSet::NamedRouteCollection::UrlHelper.prepend(Decidim::LocaleAwareNamedRouteHelper)
