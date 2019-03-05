# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # This class holds a Form to update meeting services
      class MeetingServiceForm < Decidim::Form
        include TranslatableAttributes

        attribute :deleted, Boolean, default: false

        translatable_attribute :title, String
        translatable_attribute :description, String

        validates :title, translatable_presence: true, unless: :deleted

        def to_param
          return id if id.present?

          "meeting-service-id"
        end
      end
    end
  end
end
