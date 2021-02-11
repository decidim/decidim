# frozen_string_literal: true

module Decidim
  module Admin
    class OrganizationExternalDomainWhitelistForm < Form
      attribute :external_domains, Array[Decidim::Admin::ExternalUrlForm]

      validates :external_domains_validator, presence: true

      def map_model(model)
        self.external_domains = model.external_domain_whitelist.map do |url|
          ExternalUrlForm.new(url: url)
        end
      end

      def external_domains_validator
        @external_domains_validator ||= external_domains.reject { |r| r.deleted }.map { |r| r.url }.uniq
      end
    end
  end
end
