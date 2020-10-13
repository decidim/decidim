# frozen_string_literal: true

class RenameNameColumnToTitleInDecidimParticipatoryProcessGroups < ActiveRecord::Migration[5.2]
  def up
    rename_column :decidim_participatory_process_groups, :name, :title
    PaperTrail::Version.where(item_type: "Decidim::ParticipatoryProcessGroup").each do |version|
      # rubocop:disable Rails/SkipsModelValidations
      version.update_attribute(:object_changes, version.object_changes.gsub(/^name:/, "title:")) if version.object_changes.present?
      # rubocop:enable Rails/SkipsModelValidations

      next unless version.object.present? && version.object.has_key?("name")

      object = version.object
      object["title"] = object.delete("name")

      # rubocop:disable Rails/SkipsModelValidations
      version.update_attribute(:object, object)
      # rubocop:enable Rails/SkipsModelValidations
    end
  end

  def down
    PaperTrail::Version.where(item_type: "Decidim::ParticipatoryProcessGroup").each do |version|
      # rubocop:disable Rails/SkipsModelValidations
      version.update_attribute(:object_changes, version.object_changes.gsub(/^title:/, "name:")) if version.object_changes.present?
      # rubocop:enable Rails/SkipsModelValidations

      next unless version.object.present? && version.object.has_key?("title")

      object = version.object
      object["name"] = object.delete("title")

      # rubocop:disable Rails/SkipsModelValidations
      version.update_attribute(:object, object)
      # rubocop:enable Rails/SkipsModelValidations
    end
    rename_column :decidim_participatory_process_groups, :title, :name
  end
end
