# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # This class holds a Form to create/update minutes from Decidim's admin panel.
      class MinuteForm < Decidim::Form
        include TranslatableAttributes

        mimic :meeting

        translatable_attribute :description, String

        attribute :video_url, String
        attribute :audio_url, String
        attribute :is_visible, Boolean

        validates :description, translatable_presence: true
      end
    end
  end
end
