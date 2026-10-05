# frozen_string_literal: true

class AddFailedAttemptsAndLockedAtToDecidimAuthorizations < ActiveRecord::Migration[7.0]
  def change
    add_column :decidim_authorizations, :failed_attempts, :integer, default: 0, null: false
    add_column :decidim_authorizations, :locked_at, :datetime
  end
end
