# frozen_string_literal: true

module Decidim
  module Admin
    class OrganizationExternalDomainAllowlistForm < Form
      attribute :external_domains, Array[Decidim::Admin::ExternalDomainForm]

      validate :external_domains_validator

      def map_model(model)
        self.external_domains = model.external_domain_allowlist.map do |external_domain|
          ExternalDomainForm.new(value: external_domain)
        end
      end

      def external_domains_validator
        @external_domains_validator ||= external_domains.reject(&:deleted).each do |domain|
          errors.add(:external_domains, I18n.t("decidim.admin.domain_allowlist.form.domain_too_short")) if domain.value.length <= 3
        end.map(&:value).uniq
      end
    end
  end
end
