# frozen_string_literal: true

class AddParentChildRelationToComponents < ActiveRecord::Migration[5.2]
  def change
    add_reference :decidim_components, :parent, index: true
  end
end
