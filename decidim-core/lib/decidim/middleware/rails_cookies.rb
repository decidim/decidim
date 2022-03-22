# frozen_string_literal: true

# This is a backport for Rails 6.0 for the Same-Site option for the cookies
# because this option was added in Rails 6.1.
#
# See:
# https://github.com/decidim/decidim/pull/9051
# https://github.com/rails/rails/issues/35822
# https://github.com/rails/rails/commit/7ccaa125ba396d418aad1b217b63653d06044680
module ActionDispatch
  class Cookies
    class CookieJar #:nodoc:
      alias handle_options_original handle_options

      def handle_options(options)
        handle_options_original(options)

        options[:same_site] ||= Rails.application.config.action_dispatch.cookies_same_site_protection || :lax
        options[:same_site] = false if options[:same_site] == :none
      end
    end
  end
end
