# frozen_string_literal: true

class AddCtaToNewsletters < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_newsletters, :cta_text, :jsonb
    add_column :decidim_newsletters, :cta_url, :string
  end
end
