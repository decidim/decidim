# frozen_string_literal: true

class AddResponseToDecidimConsultationsEndorsements < ActiveRecord::Migration[5.1]
  def change
    add_reference :decidim_consultations_endorsements,
                  :decidim_consultations_response,
                  foreign_key: true,
                  index: { name: "index_consultations_endorsements_on_consultations_response_id" }
  end
end
