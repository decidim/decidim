# frozen_string_literal: true
module Decidim
  # A Helper to render and link to resources.
  module OrganizationScopesHelper
    def organization_scopes(organization = current_organization)
      [Struct.new(:id, :name).new("", I18n.t("decidim.participatory_processes.scopes.global"))] + organization.scopes
    end
  end
end
