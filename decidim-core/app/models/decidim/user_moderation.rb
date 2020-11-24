# frozen_string_literal: true

module Decidim
  class UserModeration < ApplicationRecord
    include Traceable
    include Loggable

    belongs_to :user, foreign_key: :decidim_user_id, class_name: "Decidim::UserBaseEntity"
    has_many :reports, class_name: "Decidim::UserReport", dependent: :destroy

    delegate :organization, to: :user

    def self.log_presenter_class_for(_log)
      Decidim::AdminLog::UserModerationPresenter
    end
  end
end
