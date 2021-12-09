# frozen_string_literal: true

module Decidim
  class Reminder < ApplicationRecord
    self.table_name = "decidim_reminders"
    belongs_to :user, foreign_key: "decidim_user_id", class_name: "Decidim::User"
    belongs_to :component, foreign_key: "decidim_component_id", class_name: "Decidim::Component"

    def remind!
      update!(times: times << Time.current)
      ::Decidim::Admin::VoteReminderDeliveryJob.perform_later(self)
    end
  end
end
