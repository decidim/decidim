# frozen_string_literal: true

module Decidim
  module Routes
    module LocaleRedirects
      def locale_scope_options
        {
          defaults: { locale: Decidim.default_locale },
          constraints: { locale: Regexp.union(I18n.available_locales.map(&:to_s)) }
        }
      end

      def locale_redirector(path, preserve_query_string: true)
        lambda do |params, request|
          locale_redirect(params, request, path, preserve_query_string:)
        end
      end

      def locale_redirect(params, request, path, preserve_query_string: true)
        locale = Decidim::LocaleRouterDetector.new(request, params).locale
        destination = append_locale(path, locale)
        destination = append_query_string(destination, request) if preserve_query_string

        destination
      end

      private

      def append_locale(path, locale)
        return path if path == "/404"
        return path if path.start_with?("/#{locale}/") || path == "/#{locale}"

        path = "/#{path}" unless path.start_with?("/")

        "/#{locale}#{path}"
      end

      def append_query_string(path, request)
        query_string = request.query_string.to_s
        query_params = query_string.gsub(/(?:\A|&)locale=[^&]*(?=&|\z)/, "")
        query_params = query_params.gsub(/\A&|&\z/, "").gsub(/&&+/, "&")

        query_params.empty? ? path : "#{path}?#{query_params}"
      end
    end
  end
end
