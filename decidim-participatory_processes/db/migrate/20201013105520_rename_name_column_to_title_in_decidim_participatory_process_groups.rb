# frozen_string_literal: true

class RenameNameColumnToTitleInDecidimParticipatoryProcessGroups < ActiveRecord::Migration[5.2]
  def up
    rename_column :decidim_participatory_process_groups, :name, :title
    PaperTrail::Version.where(item_type: "Decidim::ParticipatoryProcessGroup").each do |version|
      # rubocop:disable-next Rails/SkipsModelValidations
      version.update_attribute(:object_changes, version.object_changes.gsub(/^name:/, "title:")) if version.object_changes.present?

      next unless version.object.present? && version.object.has_key?("name")

      object = version.object
      object["title"] = object.delete("name")

      # rubocop:disable-next Rails/SkipsModelValidations
      version.update_attribute(:object, object)
    end
  end

  def down
    PaperTrail::Version.where(item_type: "Decidim::ParticipatoryProcessGroup").each do |version|
      # rubocop:disable-next Rails/SkipsModelValidations
      version.update_attribute(:object_changes, version.object_changes.gsub(/^title:/, "name:")) if version.object_changes.present?

      next unless version.object.present? && version.object.has_key?("title")

      object = version.object
      object["name"] = object.delete("title")

      # rubocop:disable-next Rails/SkipsModelValidations
      version.update_attribute(:object, object)
    end
    rename_column :decidim_participatory_process_groups, :title, :name
  end
end
