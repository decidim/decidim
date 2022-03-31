# frozen_string_literal: true

module Decidim::Meetings
  class CalendarFilter < ApplicationRecord
    before_create :set_random_uuid

    def set_random_uuid
      self.identifier = SecureRandom.uuid if identifier.blank?
    end
  end
end
