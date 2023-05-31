# frozen_string_literal: true

require "decidim/component_validator"
require "decidim/comments"
require "decidim/dummy_resources"

RSpec.configure do |config|
  config.before(:suite) do
    ActiveRecord::Migration.suppress_messages do
      unless ActiveRecord::Base.connection.data_source_exists?("decidim_dummy_resources_dummy_resources")
        ActiveRecord::Migration.create_table :decidim_dummy_resources_dummy_resources do |t|
          t.jsonb :translatable_text
          t.jsonb :title
          t.string :body
          t.text :address
          t.float :latitude
          t.float :longitude
          t.datetime :published_at
          t.integer :coauthorships_count, null: false, default: 0
          t.integer :endorsements_count, null: false, default: 0
          t.integer :comments_count, null: false, default: 0
          t.integer :follows_count, null: false, default: 0

          t.references :decidim_component, index: false
          t.integer :decidim_author_id, index: false
          t.string :decidim_author_type, index: false
          t.integer :decidim_user_group_id, index: false
          t.references :decidim_category, index: false
          t.references :decidim_scope, index: false
          t.string :reference

          t.timestamps
        end
      end
      unless ActiveRecord::Base.connection.data_source_exists?("decidim_dummy_resources_nested_dummy_resources")
        ActiveRecord::Migration.create_table :decidim_dummy_resources_nested_dummy_resources do |t|
          t.jsonb :translatable_text
          t.string :title

          t.references :dummy_resource, index: false
          t.timestamps
        end
      end
      unless ActiveRecord::Base.connection.data_source_exists?("decidim_dummy_resources_coauthorable_dummy_resources")
        ActiveRecord::Migration.create_table :decidim_dummy_resources_coauthorable_dummy_resources do |t|
          t.jsonb :translatable_text
          t.string :title
          t.string :body
          t.text :address
          t.float :latitude
          t.float :longitude
          t.datetime :published_at
          t.integer :coauthorships_count, null: false, default: 0
          t.integer :endorsements_count, null: false, default: 0
          t.integer :comments_count, null: false, default: 0

          t.references :decidim_component, index: false
          t.references :decidim_category, index: false
          t.references :decidim_scope, index: false
          t.string :reference

          t.timestamps
        end
      end
    end
  end

  config.before do
    Decidim.find_component_manifest(:dummy).reset_hooks!
  end
end
