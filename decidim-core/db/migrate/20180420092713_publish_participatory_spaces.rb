# frozen_string_literal: true

class PublishParticipatorySpaces < ActiveRecord::Migration[5.1]
  class ParticipatorySpace < ApplicationRecord
    self.table_name = :decidim_participatory_spaces
  end

  class Organization < ApplicationRecord
    self.table_name = :decidim_organizations
  end

  def up
    %w(participatory_processes assemblies).each do |space_name|
      Organization.find_each do |organization|
        space = ParticipatorySpace.find_or_initialize_by(
          decidim_organization_id: organization.id,
          manifest_name: space_name
        )
        space.update!(activated_at: Time.current, published_at: Time.current)
      end
    end
  end

  def down; end
end
