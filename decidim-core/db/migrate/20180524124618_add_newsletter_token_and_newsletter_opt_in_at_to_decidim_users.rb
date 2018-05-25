# frozen_string_literal: true

class AddNewsletterTokenAndNewsletterOptInAtToDecidimUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_users, :newsletter_token, :string, default: ""
    add_column :decidim_users, :newsletter_opt_in_at, :datetime, default: nil
  end
end
