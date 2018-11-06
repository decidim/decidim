# frozen_string_literal: true

class AddDiplomaFieldsToConference < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_conferences, :signature_name, :string
    add_column :decidim_conferences, :signature, :string, null: false
    add_column :decidim_conferences, :main_logo, :string, null: false
    add_column :decidim_conferences, :sign_date, :date
  end
end
