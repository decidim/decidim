# frozen_string_literal: true

module Decidim
  module Admin
    class UpdateExternalDomainAllowlist < Decidim::Command
      attr_reader :form, :organization

      delegate :current_user, to: :form

      def initialize(form, organization)
        @form = form
        @organization = organization
      end

      def call
        return broadcast(:invalid) if form.invalid?

        Decidim.traceability.perform_action!("update_external_domain", @organization, current_user) do
          save_domains!
        end

        broadcast(:ok)
      end

      private

      def save_domains!
        organization.external_domain_allowlist = form.external_domains.filter_map do |external_domain_form|
          external_domain_form.value unless external_domain_form.deleted
        end.flatten

        organization.save!
      end
    end
  end
end
