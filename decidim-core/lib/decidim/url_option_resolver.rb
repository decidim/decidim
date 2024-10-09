# frozen_string_literal: true

module Decidim
  # A class for resolving the default URL options.
  class UrlOptionResolver
    def options
      {}.tap do |opts|
        opts[:host] = host if host
        opts[:port] = port unless default_port?
        opts[:protocol] = protocol if protocol == "https"
      end
    end

    def protocol
      return "https" if Rails.application.config.force_ssl || port == 443

      "http"
    end

    def host
      @host ||= begin
        default_host = nil
        default_host = "localhost" if Rails.env.local?

        ENV.fetch("HOSTNAME", default_host)
      end
    end

    def port
      @port ||= begin
        default_port =
          if Rails.env.development?
            3000
          elsif Rails.env.test?
            Capybara.server_port
          elsif Rails.application.config.force_ssl
            443
          else
            80
          end

        ENV.fetch("HTTP_PORT", default_port).to_i
      end
    end

    def default_port?
      [443, 80].include?(port)
    end
  end
end
