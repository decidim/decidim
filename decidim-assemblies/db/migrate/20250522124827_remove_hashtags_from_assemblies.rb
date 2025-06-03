# frozen_string_literal: true

class RemoveHashtagsFromAssemblies < ActiveRecord::Migration[7.0]
  def change
    remove_column :decidim_assemblies, :hashtag, :string
  end
end
