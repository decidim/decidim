# frozen_string_literal: true

# Migrates freezed assembly types to a table where to configure them
class MigrateDecidimAssemblyTypes < ActiveRecord::Migration[5.2]
  LEGACY_TYPES = {
    "government" => "Government",
    "executive" => "Executive",
    "consultative_advisory" => "Consultative/Advisory",
    "participatory" => "Participatory",
    "working_group" => "Working group",
    "commission" => "Comission",
    "others" => "Others"
  }.freeze

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
      LEGACY_TYPES.each do |type, _english|
        title = {}
        organization.available_locales.each do |lang|
          t = type_localized(type, lang)
          title[lang] = t if t
        end

        unless type == "others"
          assembly_type = AssemblyType.find_or_create_by(
            decidim_organization_id: organization.id,
            title:
          )
        end
        Assembly.where(decidim_organization_id: organization.id, assembly_type: type).each do |assembly|
          if type == "others"
            assembly_type = AssemblyType.find_or_create_by(
              decidim_organization_id: organization.id,
              title: assembly.assembly_type_other
            )
          end
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

      key = LEGACY_TYPES.find { |type, _english| type_localized(type, "en") == assembly_type.title["en"] }

      unless key
        key = "others"
        assembly.assembly_type_other = assembly_type.title
      end
      assembly.assembly_type = key
      assembly.save
    end
  end

  private

  def type_localized(type, lang)
    I18n.with_locale(lang) do
      t = I18n.t("assembly_types.#{type}", scope: "decidim.assemblies", default: false)
      t ||= LEGACY_TYPES[type] if lang == "en"
      t
    end
  end
end
