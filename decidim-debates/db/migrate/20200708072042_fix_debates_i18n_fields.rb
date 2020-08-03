# frozen_string_literal: true

class FixDebatesI18nFields < ActiveRecord::Migration[5.2]
  class User < ApplicationRecord
    self.table_name = :decidim_users
  end

  class Debate < ApplicationRecord
    self.table_name = :decidim_debates_debates
  end

  class Organization < ApplicationRecord
    self.table_name = :decidim_organizations
  end

  def change
    reset_column_information

    debates.find_each do |debate|
      locale, org_id = User.where(id: debate.decidim_author_id).pluck(:locale, :decidim_organization_id).first
      locale = locale.presence || Organization.find(org_id).default_locale
      locale = locale.to_s

      debate.title = {
        locale => debate.title[locale]
      }
      debate.description = {
        locale => debate.description[locale]
      }

      debate.save!(validate: false)
    end

    reset_column_information
  end

  def debates
    Debate
      .where.not(decidim_author_type: "Decidim::Organization")
      .select(:id, :decidim_author_id, :title, :description)
  end

  def reset_column_information
    User.reset_column_information
    Debate.reset_column_information
    Organization.reset_column_information
  end
end
