# frozen_string_literal: true

module Decidim
  module Admin
    class UpdateExternalDomainWhitelist < Decidim::Command
      attr_reader :form, :organization

      def initialize(form, organization)
        @form = form
        @organization = organization
      end

      def call
        return broadcast(:invalid) if form.invalid?

        save_domains!

        broadcast(:ok)
      end

      private

      def save_domains!
        organization.external_domain_whitelist = form.external_domains.filter_map do |external_domain_form|
          external_domain_form.value unless external_domain_form.deleted
        end.flatten

        organization.save!
      end
    end
  end
end
