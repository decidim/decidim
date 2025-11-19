# frozen_string_literal: true

class AddDummyMigration < ActiveRecord::Migration[7.2]
  def up
    # This migration is not doing anything. It is just here as a mere placeholder.
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
