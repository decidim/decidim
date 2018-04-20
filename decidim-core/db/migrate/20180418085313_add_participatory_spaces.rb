# frozen_string_literal: true

class AddParticipatorySpaces < ActiveRecord::Migration[5.1]
  class ParticipatorySpace < ApplicationRecord
    self.table_name = :decidim_participatory_spaces
  end

  class Organization < ApplicationRecord
    self.table_name = :decidim_organizations
  end

  def up
    create_table :decidim_participatory_spaces do |t|
      t.integer :decidim_organization_id, null: false
      t.string :manifest_name, null: false
      t.datetime :activated_at
      t.datetime :published_at
    end

    %w(participatory_processes assemblies).each do |space_name|
      Organization.find_each do |organization|
        space = ParticipatorySpace.find_or_create_by(
          organization: organization,
          manifest_name: space_name
        )
        space.activate!
        space.publish!
      end
    end
  end

  def down
    drop_table :decidim_participatory_spaces
  end
end
