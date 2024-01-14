# frozen_string_literal: true

class ChangeDefaultValueForDecidimEndorsements < ActiveRecord::Migration[6.1]
  def up
    change_column_default :decidim_endorsements, :decidim_user_group_id, 0
  end

  def down
    change_column_default :decidim_endorsements, :decidim_user_group_id, nil
  end
end
