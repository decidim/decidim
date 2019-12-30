# frozen_string_literal: true

class AddResponseGroupsToDecidimConsultationsResponses < ActiveRecord::Migration[5.2]
  def change
    add_reference :decidim_consultations_responses,
                  :decidim_consultations_response_group,
                  foreign_key: true,
                  index: { name: "index_consultations_response_groups_on_consultation_responses" }
  end
end
