# frozen_string_literal: true

module Decidim
  # A moderation belongs to a reportable and includes many reports
  class Moderation < ApplicationRecord
    belongs_to :reportable, foreign_key: "decidim_reportable_id", foreign_type: "decidim_reportable_type", polymorphic: true, optional: true
    belongs_to :participatory_space, foreign_key: "decidim_participatory_space_id", foreign_type: "decidim_participatory_space_type", polymorphic: true
    has_many :reports, foreign_key: "decidim_moderation_id", class_name: "Decidim::Report", dependent: :destroy

    delegate :feature, :organization, to: :reportable


    def authorized?
      upstream_moderation == "authorized"
    end

    def unmoderated?
      upstream_moderation == "unmoderate"
    end

    def authorize!
      update_attributes(upstream_moderation: "authorized")
      if reportable.class.name.demodulize == "Comment"
        reportable.send_notification
      end
    end

    def refuse!
      update_attributes(upstream_moderation: "refused")
    end
  end
end
