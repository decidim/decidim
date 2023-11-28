# frozen_string_literal: true

class RemoveOfficialImgHeader < ActiveRecord::Migration[6.1]
  def up
    remove_column :decidim_organizations, :official_img_header
  end

  def down
    add_column :decidim_organizations, :official_img_header, :string
  end
end
