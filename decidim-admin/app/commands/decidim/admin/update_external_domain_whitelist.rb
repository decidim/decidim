# frozen_string_literal: true

module Decidim
  module Admin
    class UpdateExternalDomainWhitelist < Rectify::Command
      attr_reader :form

      def initialize(form)
        @form = form
      end

      def call
        return broadcast(:invalid) if form.invalid?

        raise form.add_external_domain.inspect
        current_organization.external_domain_whitelist = form.add_external_domain

        broadcast(:ok)
      end
    end
  end
end
