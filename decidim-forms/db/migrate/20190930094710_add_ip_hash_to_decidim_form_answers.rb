# frozen_string_literal: true

class AddIpHashToDecidimFormAnswers < ActiveRecord::Migration[5.2]
  class Answer < ApplicationRecord
    self.table_name = :decidim_forms_answers
  end

  def change
    add_column :decidim_forms_answers, :ip_hash, :string
    add_index :decidim_forms_answers, :ip_hash
  end
end
