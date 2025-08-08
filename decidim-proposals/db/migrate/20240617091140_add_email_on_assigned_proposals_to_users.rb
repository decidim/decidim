# frozen_string_literal: true

class AddEmailOnAssignedProposalsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :decidim_users, :email_on_assigned_proposals, :boolean, default: true
  end
end
