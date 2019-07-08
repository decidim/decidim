class AddResponseGroupsToDecidimConsultationsResponses < ActiveRecord::Migration[5.2]
  def change
    add_reference :decidim_consultations_response_groups,
                  :decidim_consultations_response_group,
                  foreign_key: true,
                  index: { name: "index_consultations_response_groups_on_consultation_responses" }
  end
end
