# frozen_string_literal: true

module Decidim
  module Admin
    class OrganizationExternalDomainWhitelistForm < Form
      attribute :external_domains, Array[Decidim::Admin::ExternalDomainForm]

      validates :external_domains_validator, presence: true

      def map_model(model)
        # raise model.inspect
        # raise model.external_domain_whitelist.inspect
        # raise model.external_domain_whitelist.length.inspect
        self.external_domains = model.external_domain_whitelist.map do |external_domain|
          ExternalDomainForm.new(value: external_domain)
        end
      end

      def external_domains_validator
        @external_domains_validator ||= external_domains.reject { |r| r.deleted }.map { |r| r.value }.uniq
      end
    end
  end
end
