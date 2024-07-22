# frozen_string_literal: true

class ChangeObjectChangesOnVersions < ActiveRecord::Migration[6.1]
  def up
    permitted_classes = [
      ::ActiveRecord::Type::Time::Value,
      ::ActiveSupport::TimeWithZone,
      ::ActiveSupport::TimeZone,
      ::BigDecimal,
      ::Date,
      ::Symbol,
      ::Time,
      ::TrueClass,
      ::FalseClass,
      ::NilClass,
      ::Numeric,
      ::String,
      ::Array,
      ::Hash
    ]

    rename_column :versions, :object_changes, :old_object_changes
    add_column :versions, :object_changes, :jsonb # or :json

    PaperTrail::Version.where.not(old_object_changes: nil).find_each do |version|
      version.update_columns old_object_changes: nil, object_changes: Psych.safe_load(version.old_object_changes, permitted_classes:, aliases: true)
    end

    remove_column :versions, :old_object_changes
  end
end
