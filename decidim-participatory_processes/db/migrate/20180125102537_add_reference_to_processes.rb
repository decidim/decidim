# frozen_string_literal: true

class AddReferenceToProcesses < ActiveRecord::Migration[5.1]
  class ParticipatoryProcess < ApplicationRecord
    self.table_name = :decidim_participatory_processes
  end

  def change
    add_column :decidim_participatory_processes, :reference, :string
    ParticipatoryProcess.find_each(&:touch)
  end
end
