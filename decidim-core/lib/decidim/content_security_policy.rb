# frozen_string_literal: true

module Decidim
  class ContentSecurityPolicy
    def initialize(organization = nil)
      @organization = organization
      @policy = Decidim.content_security_policy
    end

    def output_policy
      add_system_csp_directives
      organization_csp_directives

      policy.map do |directive, values|
        [directive, values.join(" ")].join(" ")
      end.join("; ")
    end

    def append_csp_directive(directive, value)
      policy[directive] ||= []
      policy[directive] << value
      policy[directive].uniq!
    end

    private

    attr_reader :policy, :organization

    def organization_csp_directives
      return unless organization

      organization.content_security_policy.each do |directive, value|
        value.split.each do |v|
          append_csp_directive(directive, v) if v.present?
        end
      end
    end

    def add_system_csp_directives
      if Rails.configuration.action_controller.asset_host
        %w(media-src img-src script-src style-src).each do |directive|
          append_csp_directive(directive, Rails.configuration.action_controller.asset_host)
        end
      end
    end
  end
end
