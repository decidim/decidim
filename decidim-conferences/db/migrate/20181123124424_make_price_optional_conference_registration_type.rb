# frozen_string_literal: true

class MakePriceOptionalConferenceRegistrationType < ActiveRecord::Migration[5.2]
  def change
    change_column_null(:decidim_conferences_registration_types, :price, true)
  end
end
