# frozen_string_literal: true

class AddDemocraticQualityStaticPage < ActiveRecord::Migration[7.0]
  def up
    Decidim::Organization.find_each do |organization|
      Decidim::ParticipatoryProcesses::CreateDemocraticQualityIndicatorsPage.call(organization)
    end
  end
end
