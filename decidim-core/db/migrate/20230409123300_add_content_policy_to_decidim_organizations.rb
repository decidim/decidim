# frozen_string_literal: true

class AddContentPolicyToDecidimOrganizations < ActiveRecord::Migration[6.1]
  def change
    add_column :decidim_organizations, :content_security_policy, :jsonb, default: {}
  end
end
