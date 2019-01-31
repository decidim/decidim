# frozen_string_literal: true

class AddExtraFieldsLegalInformationToInitiativesTypes < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_initiatives_types, :extra_fields_legal_information, :jsonb
  end
end
