class RemoveHashtagsFromAssemblies < ActiveRecord::Migration[7.0]
  def change
    remove_column :decidim_assemblies, :hashtags, :string
  end
end
