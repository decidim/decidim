# frozen_string_literal: true

class RemoveUnusedAttributesFromInitiative < ActiveRecord::Migration[5.1]
  def change
    remove_column :decidim_initiatives, :banner_image, :string
    remove_column :decidim_initiatives, :decidim_scope_id, :integer, index: true
    remove_column :decidim_initiatives, :type_id, :integer, index: true
  end
end
