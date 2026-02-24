# frozen_string_literal: true

class RemoveEnableParticipatorySpaceFiltersFromDecidimOrganizations < ActiveRecord::Migration[7.2]
  def change
    remove_column :decidim_organizations, :enable_participatory_space_filters, :boolean
  end
end
