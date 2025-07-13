# frozen_string_literal: true

class RemoveColumnShowStatisticsFromAssemblies < ActiveRecord::Migration[7.0]
  def change
    remove_column :decidim_assemblies, :show_statistics, :string
  end
end
