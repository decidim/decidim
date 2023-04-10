# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module ContentSecurityPolicy
    extend ActiveSupport::Concern

    included do
      before_action :initialize_content_security_policy

      after_action :set_organization_content_security_policy
    end

    private

    attr_reader :additional_csp

    def set_organization_content_security_policy
      return unless respond_to?(:current_organization)
      return unless current_organization

      current_organization.content_security_policy.each do |directive, value|
        value.split(" ").each do |v|
          append_csp_directive(directive, v) unless v.blank?
        end
      end
      
      policy = additional_csp.map do |directive, values|
        [directive, values.join(" ")].join(" ")
      end

      response.headers["Content-Security-Policy"] = policy.join("; ")
    end

    def append_csp_directive(directive, value)
      additional_csp[directive] ||= []
      additional_csp[directive] << value
      additional_csp[directive].uniq!
    end

    def initialize_content_security_policy
      @additional_csp = Decidim.content_security_policy.clone
    end
  end
end
