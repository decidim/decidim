# frozen_string_literal: true

module Decidim
  # Overrides {ActiveLinkTo#is_active_link?} to handle locale-prefixed URLs.
  #
  # Decidim adds the locale as a URL path segment (e.g. `/en/processes`), so
  # the URL passed to the helper and `request.original_fullpath` both carry a
  # locale prefix. This module normalizes the URL argument to always carry the
  # current locale prefix before delegating to the gem, so active-state
  # detection works correctly regardless of whether the caller already included
  # the locale in the URL or not.
  #
  # When the locale is part of the Rails script name rather than the path
  # (i.e. the application is mounted at a locale-prefixed mount point), no
  # normalization is performed and the original gem behaviour is preserved.
  #
  # Include this module *after* {ActiveLinkTo} so that this override takes
  # precedence.
  module ActiveLinkToHelper
    # Overrides {ActiveLinkTo#is_active_link?} to normalise locale-prefixed
    # URLs before comparison.
    #
    # @param url [String] the URL to check
    # @param condition [Boolean, Symbol, Regexp, Array, Hash, nil] the active
    #   condition, same as accepted by the `active_link_to` gem
    #
    # @return [Boolean] whether the link is considered active
    def is_active_link?(url, condition = nil) # rubocop:disable Naming/PredicatePrefix
      super(locale_prefixed_url(url), condition)
    end

    private

    # Normalizes a URL so its path carries the current locale prefix, but only
    # when the current request path itself has a locale prefix. This preserves
    # correct behaviour in engines mounted without a locale segment (e.g. the
    # admin engine at +/admin+) where neither the request path nor the
    # generated paths contain a locale segment.
    #
    # When normalization does apply, any existing locale prefix is stripped
    # first to avoid double-prefixing.
    #
    # Returns the URL unchanged for non-String values, when no locale segments
    # are configured, when the locale lives in the script name, or when the
    # current request path has no locale prefix.
    #
    # @param url [String] the URL to normalize
    #
    # @return [String] the normalized URL
    def locale_prefixed_url(url)
      locale_pattern = locale_prefix_pattern
      return url unless normalizable_url?(url, locale_pattern)

      current = try(:current_locale) || I18n.locale.to_s
      return url if current.blank?

      rewrite_url_with_locale(url, locale_pattern, current)
    end

    # Determines whether a URL string should be normalized with a locale prefix.
    #
    # Returns +false+ when any of the following conditions are true:
    # - +url+ is not a +String+
    # - the locale lives in the script name (via +locale_in_script_name?+)
    # - +locale_pattern+ is +nil+ (no locales are configured)
    # - the current request path does not begin with a locale segment
    #
    # @param url [String] the URL candidate for normalization
    # @param locale_pattern [Regexp, nil] the pattern built by {#locale_prefix_pattern},
    #   or +nil+ when no locales are available
    #
    # @return [Boolean] +true+ when the URL should be rewritten with a locale prefix
    def normalizable_url?(url, locale_pattern)
      return false unless url.is_a?(String)
      return false if try(:locale_in_script_name?)
      return false if locale_pattern.nil?

      current_path = try(:request)&.original_fullpath.to_s
      current_path.match?(locale_pattern)
    end

    # Builds a +Regexp+ that matches any available locale code at the start of a
    # URL path segment (e.g. +/en+, +/zh-TW+).
    #
    # Locales are sorted longest-first so that longer codes such as +zh-TW+ are
    # tried before shorter ones like +zh+, preventing partial matches.
    #
    # @return [Regexp, nil] the locale-matching pattern, or +nil+ when no locales
    #   are configured
    def locale_prefix_pattern
      locales = available_locale_segments
      return if locales.empty?

      %r{\A/(#{Regexp.union(locales)})(?=/|\z)}
    end

    # Rewrites the path component of +url+ so it begins with the +current+ locale
    # prefix. Any preexisting locale prefix is stripped first to prevent
    # double-prefixing (e.g. +/en/en/foo+ would never be produced).
    #
    # Returns +url+ unchanged when the URI cannot be parsed.
    #
    # @param url [String] the URL whose path should be rewritten
    # @param locale_pattern [Regexp] the pattern used to strip an existing locale prefix
    # @param current [String] the locale code to prepend (e.g. +"en"+ or +"zh-TW"+)
    #
    # @return [String] the URL with its path rewritten to carry +current+ as the
    #   leading segment, or the original +url+ if parsing fails
    def rewrite_url_with_locale(url, locale_pattern, current)
      uri = Addressable::URI.parse(url)
      return url if uri.nil?

      stripped_path = uri.path.to_s.sub(locale_pattern, "")
      stripped_path = "/" if stripped_path.empty?

      uri.path = "/#{current}#{stripped_path}"
      uri.to_s
    rescue Addressable::URI::InvalidURIError
      url
    end

    # Returns the list of available locale codes sorted longest-first.
    #
    # Sorting longest-first ensures that longer locale codes (e.g. +zh-TW+) are
    # matched before shorter ones (e.g. +zh+) when building a {#locale_prefix_pattern}.
    #
    # Falls back to {Decidim.available_locales} when +available_locales+ is not
    # defined on the including context (e.g. outside a controller).
    #
    # @return [Array<String>] locale code strings sorted by descending length
    def available_locale_segments
      locales = try(:available_locales) || Decidim.available_locales
      locales.map(&:to_s).sort_by(&:length).reverse
    end
  end
end
