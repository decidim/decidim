# frozen_string_literal: true

class AddReferenceToAssemblies < ActiveRecord::Migration[5.1]
  class Assembly < ApplicationRecord
    self.table_name = :decidim_assemblies
  end

  def change
    add_column :decidim_assemblies, :reference, :string
    Assembly.find_each(&:touch)
  end
end
