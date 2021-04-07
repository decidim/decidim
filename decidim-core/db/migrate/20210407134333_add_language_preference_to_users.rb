class AddLanguagePreferenceToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_users, :language_preference, :string
  end
end
