# frozen_string_literal: true

# Handle the locale redirects in the route files
# It tries to detect a place where the locale is being present, either as a GET parameter,
# or a session, or if there is nothing it will return the default locale of the organization.
module Decidim
  class LocaleRouterDetector
    def initialize(request, params)
      @request = request
      @input_params = params
    end

    def locale
      available_locales.map(&:to_sym).include?(extracted_locale.to_sym) ? extracted_locale : default_locale
    end

    private

    attr_reader :request, :input_params

    def extracted_locale
      input_params[:locale].presence ||
        request.parameters[:locale].presence ||
        current_user_locale ||
        request.session[:user_locale].presence ||
        accept_language_locale ||
        I18n.locale
    end

    def current_user_locale
      request.env["warden"]&.user("user")&.locale.presence
    end

    def accept_language_locale
      header = request.env["HTTP_ACCEPT_LANGUAGE"]
      return if header.blank?

      languages = accept_languages(header)
      language = exact_accept_language(languages) || prefix_accept_language(languages)
      language == "*" ? nil : language
    end

    def accept_languages(header)
      languages = header.gsub(/[^a-z0-9\-;,=.]/i, "").split(",").each_with_index.map do |language, index|
        language += ";q=1.0" unless language =~ /;q=\d+(?:\.\d+)?$/
        name, quality = language.split(";q=")
        [name, quality.to_f - (index.to_f / 1000)]
      end

      languages.sort_by { |(_name, quality)| quality }.reverse.map(&:first)
    end

    def exact_accept_language(languages)
      languages.detect { |name| name == "*" || available_locales.map(&:to_s).include?(name.to_s) }
    end

    def prefix_accept_language(languages)
      available_locales.detect do |available|
        languages.any? { |name| name.to_s[0..1] == available.to_s[0..1] }
      end
    end

    def available_locales
      (organization || Decidim).available_locales
    end

    def default_locale
      (organization || Decidim).default_locale
    end

    def organization
      request.env["decidim.current_organization"]
    end
  end
end
