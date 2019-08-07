# frozen_string_literal: true

class CreateStaticPages < ActiveRecord::Migration[5.1]
  class Organization < ApplicationRecord
    self.table_name = :decidim_organizations
  end

  class StaticPage < ApplicationRecord
    self.table_name = :decidim_static_pages
  end

  def change
    Organization.find_each do |organization|
      StaticPage.find_or_create_by!(slug: "initiatives") do |page|
        page.decidim_organization_id = organization.id
        page.title = localized_attribute(organization, "initiatives", :title)
        page.content = localized_attribute(organization, "initiatives", :content)
      end
    end
  end

  private

  def localized_attribute(organization, slug, attribute)
    organization.available_locales.inject({}) do |result, locale|
      text = I18n.with_locale(locale) do
        I18n.t(attribute, scope: "decidim.system.default_pages.placeholders", page: slug)
      end

      result.update(locale => text)
    end
  end
end
