# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # This class holds a Form to create/update minutes from Decidim's admin panel.
      class MinutesForm < Decidim::Form
        include TranslatableAttributes

        translatable_attribute :description, String

        attribute :video_url, String
        attribute :audio_url, String
        attribute :visible, Boolean

        validates :description, translatable_presence: true
      end
    end
  end
end
