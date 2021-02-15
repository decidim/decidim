# frozen_string_literal: true

module Decidim
  module Admin
    class OrganizationExternalDomainWhitelistForm < Form
      attribute :external_domains, Array[Decidim::Admin::ExternalDomainForm]

      validates :external_domains_validator, presence: true

      def map_model(model)
        self.external_domains = model.external_domain_whitelist.map do |external_domain|
          ExternalDomainForm.new(value: external_domain)
        end
      end

      def external_domains_validator
        @external_domains_validator ||= external_domains.reject(&:deleted).map(&:value).uniq
      end
    end
  end
end
