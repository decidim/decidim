# frozen_string_literal: true

class AddEndVotingDateToDecidimConsultations < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_consultations, :end_voting_date, :date

    Decidim::Consultation.find_each do |consultation|
      consultation.end_voting_date = consultation.start_voting_date + 1.month
      consultation.save
    end

    change_column_null :decidim_consultations, :end_voting_date, false
  end
end
