# frozen_string_literal: true

class AddAssemblyMembers < ActiveRecord::Migration[5.1]
  def change
    create_table :decidim_assembly_members do |t|
      t.references :decidim_assembly, index: true
      t.integer :weight, null: false, default: 0
      t.string :full_name
      t.string :gender
      t.string :origin
      t.date :birthday
      t.date :designation_date
      t.string :designation_mode
      t.string :position
      t.string :position_other
      t.date :ceased_date

      t.timestamps
    end
  end
end
