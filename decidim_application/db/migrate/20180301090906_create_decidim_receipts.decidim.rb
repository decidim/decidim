# This migration comes from decidim (originally 20171117100533)
# frozen_string_literal: true

class CreateDecidimReceipts < ActiveRecord::Migration[5.1]
  def change
    create_table :decidim_messaging_receipts do |t|
      t.references :decidim_message, null: false
      t.references :decidim_recipient, null: false
      t.datetime :read_at

      t.timestamps
    end
  end
end
