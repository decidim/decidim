# frozen_string_literal: true

class RemoveHastagsColumnAssemblies < ActiveRecord::Migration[7.1]
  def change
    remove_column :decidim_assemblies, :hashtag, :string, if_exists: true
  end
end
