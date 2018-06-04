class CreateParticipantsViews < ActiveRecord::Migration[5.2]
  def change
    create_view :participants_views, materialized: true
  end
end
