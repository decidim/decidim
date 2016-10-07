# frozen_string_literal: true
module Decidim
  # Main module to add application-wide helpers.
  module ApplicationHelper
    def link_to_organization(organization)
      link_to(organization.name, root_url(host: organization.host))
    end
  end
end
