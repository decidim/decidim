# frozen_string_literal: true

class ChangeObjectChangesOnVersions < ActiveRecord::Migration[6.1]
  def up
    rename_column :versions, :object_changes, :old_object_changes
    add_column :versions, :object_changes, :jsonb # or :json

    PaperTrail::Version.where.not(old_object_changes: nil).find_each do |version|
      # This is an adaptation of PaperTrail internal load_changeset method,having in mind that we
      # need to call also the code from PaperTrail::AttributeSerializer::ObjectChangesAttribute
      object_changes = ActiveSupport::HashWithIndifferentAccess.new(YAML.unsafe_load(version.old_object_changes))
      unless version.item_type.constantize.unscoped.find_by(id: version.item_id).nil?
        # This is the deserialization code from `PaperTrail::AttributeSerializer::ObjectChangesAttribute`
        # where we skip checking the object changeset column type, as we migrate it from YAML to JSON
        changes_to_serialize = object_changes.clone
        if changes_to_serialize.present?
          serializer = PaperTrail::AttributeSerializers::CastAttributeSerializer.new(version.item_type.constantize)
          changes_to_serialize.each do |key, change|
            # `change` is an Array with two elements, representing before and after.
            object_changes[key] = Array(change).map do |value|
              serializer.send(:deserialize, key, value)
            end
          end
        end
      end

      version.update_columns(old_object_changes: nil, object_changes:) # rubocop:disable Rails/SkipsModelValidations
    rescue NameError
      Rails.logger.info "Skipping History of #{version.item_type} with id #{version.item_id}"
    end

    PaperTrail::Version.reset_column_information
    remove_column :versions, :old_object_changes
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
