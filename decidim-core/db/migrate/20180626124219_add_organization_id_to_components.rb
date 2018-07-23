# frozen_string_literal: true

class AddOrganizationIdToComponents < ActiveRecord::Migration[5.2]
  class Component < ApplicationRecord
    self.table_name = :decidim_components
    belongs_to :participatory_space, polymorphic: true
  end

  def up
    add_reference :decidim_components, :decidim_organization, index: true

    Component.find_each do |component|
      component.update(decidim_organization_id: component.participatory_space.decidim_organization_id)
    end
  end

  def down
    remove_reference :decidim_components, :decidim_organization, index: true
  end
end
