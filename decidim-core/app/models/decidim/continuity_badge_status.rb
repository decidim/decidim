# frozen_string_literal: true

module Decidim
  class ContinuityBadgeStatus < ApplicationRecord
    belongs_to :subject, polymorphic: true

    validates :subject, :current_streak, :last_session_at, presence: true
  end
end
