# frozen_string_literal: true

module Decidim
  module Admin
    class OrganizationExternalDomainWhitelistForm < Form
      attribute :whitelist, Array
      attribute :add_external_domain, String

      def map_model(whitelist)
        self.whitelist = whitelist
      end
    end
  end
end
