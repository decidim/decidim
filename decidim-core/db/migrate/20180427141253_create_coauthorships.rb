class CreateCoauthorships < ActiveRecord::Migration[5.1]
  def change
    create_table :coauthorships do |t|
      t.references :decidim_author, null: false, index: { name: "index_author_on_coauthorsihp" }
      t.references :decidim_user_group, index: { name: "index_user_group_on_coauthorsihp" }
      t.references :coauthorable,  polymorphic: true, index: { name: "index_coauthorable_on_coauthorship" }

      t.timestamps
    end
  end
end
