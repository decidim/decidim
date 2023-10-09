# frozen_string_literal: true

module Decidim
  # This class is responsible of generating the Content-Security-Policy header
  # for the application. It takes into account the organization's CSP settings
  # and the additional settings defined in the initializer.
  class ContentSecurityPolicy
    SUPPORTED_POLICIES = %w(
      child-src
      connect-src
      default-src
      font-src
      frame-src
      img-src
      manifest-src
      media-src
      object-src
      prefetch-src
      script-src
      script-src-elem
      script-src-attr
      style-src-elem
      style-src-attr
      worker-src
      base-uri
      sandbox
      form-action
      frame-ancestors
      navigate-to
      report-uri
      report-to
      require-trusted-types-for
      trusted-types
      upgrade-insecure-requests
      style-src
    ).freeze

    def initialize(organization = nil, additional_policies = {})
      @organization = organization
      @policy = default_policy
      @additional_policies = additional_policies.stringify_keys
    end

    def output_policy
      add_system_csp_directives
      add_additional_policies
      organization_csp_directives
      append_development_directives

      format_policies
    end

    def append_csp_directive(directive, value)
      return if value.blank?

      message = "Invalid Content Security Policy directive: #{directive}, supported directives: #{SUPPORTED_POLICIES.join(", ")}"
      raise message unless SUPPORTED_POLICIES.include?(directive)

      policy[directive] ||= []
      policy[directive] << value
    end

    private

    attr_reader :policy, :organization, :additional_policies

    def append_development_directives
      return unless Rails.env.development?

      host = ::Shakapacker.config.dev_server[:host]
      port = ::Shakapacker.config.dev_server[:port]

      append_csp_directive("connect-src", "wss://#{host}:#{port}")
      append_csp_directive("connect-src", "ws://#{host}:#{port}")
    end

    def format_policies
      policy.map do |directive, values|
        [directive, values.uniq.join(" ")].join(" ")
      end.join("; ")
    end

    def append_multiple_csp_directives(directive, values)
      values.each do |v|
        append_csp_directive(directive, v)
      end
    end

    def add_additional_policies
      additional_policies.each do |directive, values|
        next if values.blank?

        values = values.split if values.is_a?(String)

        raise "Invalid value for additional CSP policy #{directive}: #{values.inspect}" unless values.is_a?(Array)

        append_multiple_csp_directives(directive, values)
      end
    end

    def organization_csp_directives
      return unless organization

      organization.content_security_policy.each do |directive, value|
        append_multiple_csp_directives(directive, value.split) if value.present?
      end
    end

    def add_system_csp_directives
      return unless Rails.configuration.action_controller.asset_host

      %w(media-src img-src script-src style-src).each do |directive|
        append_csp_directive(directive, Rails.configuration.action_controller.asset_host)
      end
    end

    # rubocop:disable Lint/PercentStringArray
    def default_policy
      {
        "default-src" => %w('self' 'unsafe-inline'),
        "script-src" => %w('self' 'unsafe-inline' 'unsafe-eval'),
        "style-src" => %w('self' 'unsafe-inline'),
        "img-src" => %w('self' *.hereapi.com data:),
        "font-src" => %w('self'),
        "connect-src" => %w('self' *.hereapi.com *.jsdelivr.net data:),
        "frame-src" => %w('self' www.youtube-nocookie.com player.vimeo.com),
        "media-src" => %w('self')
      }
    end
    # rubocop:enable Lint/PercentStringArray
  end
end
