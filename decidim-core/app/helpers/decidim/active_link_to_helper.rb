# frozen_string_literal: true

module Decidim
  # Overrides {ActiveLinkTo#is_active_link?} to handle locale-prefixed URLs.
  #
  # Decidim adds the locale as a URL path segment (e.g. `/en/processes`), so
  # the URL passed to the helper and `request.original_fullpath` both carry a
  # locale prefix. This module normalises the URL argument to always carry the
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
    def is_active_link?(url, condition = nil) # rubocop:disable Naming/PredicateName
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
      return url unless url.is_a?(String)
      return url if try(:locale_in_script_name?)

      locales = available_locale_segments
      return url if locales.empty?

      locale_pattern = %r{\A/(#{Regexp.union(locales)})(?=/|\z)}

      # Only normalize when the current request path itself carries a locale
      # prefix. In engines mounted without a locale segment (e.g. the admin
      # engine at /admin), request.original_fullpath has no locale prefix and
      # path helpers generate paths without one, so normalization would
      # incorrectly add a prefix and break active-state detection.
      current_path = try(:request)&.original_fullpath.to_s
      return url unless current_path.match?(locale_pattern)

      current = try(:current_locale) || I18n.locale.to_s
      return url if current.blank?

      begin
        uri = Addressable::URI.parse(url)
        return url if uri.nil?

        path = uri.path.to_s

        # Strip any existing locale prefix so we never double-prefix
        stripped_path = path.sub(locale_pattern, "")
        stripped_path = "/" if stripped_path.empty?

        uri.path = "/#{current}#{stripped_path}"
        uri.to_s
      rescue Addressable::URI::InvalidURIError
        url
      end
    end

    # Returns the list of available locale segments sorted longest-first to
    # ensure longer locale codes (e.g. `zh-TW`) are matched before shorter
    # ones.
    #
    # @return [Array<String>] sorted locale strings
    def available_locale_segments
      locales = try(:available_locales) || Decidim.available_locales
      locales.map(&:to_s).sort_by(&:length).reverse
    end
  end
end
