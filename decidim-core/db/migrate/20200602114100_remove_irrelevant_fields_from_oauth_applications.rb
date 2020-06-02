# frozen_string_literal: true

class RemoveIrrelevantFieldsFromOAuthApplications < ActiveRecord::Migration[5.2]
  def change
    remove_column :oauth_applications, :organization_name
    remove_column :oauth_applications, :organization_url
    remove_column :oauth_applications, :organization_logo
  end
end
