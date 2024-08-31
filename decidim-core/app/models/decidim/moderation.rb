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

    scope :hidden, -> { where.not(hidden_at: nil) }
    scope :not_hidden, -> { where(hidden_at: nil) }

    def self.log_presenter_class_for(_log)
      Decidim::AdminLog::ModerationPresenter
    end

    ransacker :reported_id_string do
      Arel.sql(%{cast("decidim_moderations"."decidim_reportable_id" as text)})
    end

    ransacker :reported_content do
      Arel.sql(%{cast("decidim_moderations"."reported_content" as text)})
    end

    ransacker :reportable_type_string do
      Arel.sql(%{cast("decidim_moderations"."decidim_reportable_type" as text)})
    end

    def self.ransackable_attributes(_auth_object = nil)
      # %w(created_at decidim_participatory_space_id decidim_participatory_space_type decidim_reportable_id decidim_reportable_type hidden_at id report_count
      #    reportable_type_string reported_content reported_id_string updated_at)
      base = %w()

      return base unless _auth_object&.admin?

      base + %w()
    end

    def self.ransackable_associations(_auth_object = nil)
      # %w(participatory_space reportable reports versions)
      []
    end

  end
end
