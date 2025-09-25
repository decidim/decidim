# frozen_string_literal: true

class AddDemocraticQualityStaticPage < ActiveRecord::Migration[7.0]
  class Organization < ApplicationRecord
    self.table_name = :decidim_organizations
  end

  class StaticPage < ApplicationRecord
    self.table_name = :decidim_static_pages
  end

  def up
    Organization.find_each do |organization|
      Decidim::ParticipatoryProcesses::CreateDemocraticQualityIndicatorsPage.call(organization)
    end
  end
end
