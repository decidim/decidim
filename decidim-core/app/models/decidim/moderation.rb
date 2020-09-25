# frozen_string_literal: true

module Decidim
  # A moderation belongs to a reportable and includes many reports
  class Moderation < ApplicationRecord
    include Traceable
    include Loggable

    belongs_to :reportable, foreign_key: "decidim_reportable_id", foreign_type: "decidim_reportable_type", polymorphic: true, touch: true
    belongs_to :participatory_space, foreign_key: "decidim_participatory_space_id", foreign_type: "decidim_participatory_space_type", polymorphic: true
    has_many :reports, foreign_key: "decidim_moderation_id", class_name: "Decidim::Report", dependent: :destroy

    delegate :component, :organization, to: :reportable

    def self.log_presenter_class_for(_log)
      Decidim::AdminLog::ModerationPresenter
    end
  end
end
