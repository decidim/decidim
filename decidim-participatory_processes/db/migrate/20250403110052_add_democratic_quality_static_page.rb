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
      StaticPage.find_or_create_by!(slug: "democratic-quality-indicators") do |page|
        page.decidim_organization_id = organization.id
        page.title = localized_attribute(organization, :title)
        page.content = localized_attribute(organization, :content)
        page.allow_public_access = true
      end
    end
  end

  private

  def localized_attribute(organization, attribute)
    organization.available_locales.inject({}) do |result, locale|
      text = I18n.with_locale(locale) do
        I18n.t(attribute, scope: "decidim.participatory_processes.static_pages.democratic_quality_indicators")
      end

      result.update(locale => text)
    end
  end
end
