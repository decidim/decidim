# frozen_string_literal: true

# Migrates freezed assembly types to a table where to configure them
class MigrateDecidimAssemblyTypes < ActiveRecord::Migration[5.2]
  LEGACY_TYPES = %w(government executive consultative_advisory participatory working_group commission others).freeze

  class Organization < ApplicationRecord
    self.table_name = :decidim_organizations
  end

  class Assembly < ApplicationRecord
    self.table_name = :decidim_assemblies
  end

  class AssemblyType < ApplicationRecord
    self.table_name = :decidim_assemblies_types
  end

  def up
    Organization.find_each do |organization|
      LEGACY_TYPES.each do |type|
        title = {}
        organization.available_locales.each do |lang|
          I18n.with_locale(lang) do
            title[lang] = I18n.t("assembly_types.#{type}", scope: "decidim.assemblies")
          end
        end
        assembly_type = AssemblyType.create(
          decidim_organization_id: organization.id,
          title: title
        )
        Assembly.where(decidim_organization_id: organization.id, assembly_type: type).each do |assembly|
          assembly.decidim_assemblies_type_id = assembly_type.id
          assembly.save
        end
      end
    end
  end

  def down
    Assembly.find_each do |assembly|
      next unless assembly.decidim_assemblies_type_id

      assembly_type = AssemblyType.find(assembly.decidim_assemblies_type_id)
      next unless assembly_type

      key = LEGACY_TYPES.find { |type| I18n.with_locale("en") { I18n.t("assembly_types.#{type}", scope: "decidim.assemblies") } == assembly_type.title["en"] }
      assembly.assembly_type = key
      assembly.save
    end
  end
end
