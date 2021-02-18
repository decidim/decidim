# frozen_string_literal: true

class AddDefaultWhitelistToOrganizations < ActiveRecord::Migration[5.2]
  class Organization < ApplicationRecord
    self.table_name = "decidim_organizations"
  end

  def up
    Organization.find_each do |organization|
      organization.update!(external_domain_whitelist: ["decidim.org", "github.com"])
    end
  end
end
