# frozen_string_literal: true

module Decidim
  class Amendment < ApplicationRecord
    STATES = %w(draft evaluating accepted rejected withdrawn).freeze

    belongs_to :amendable, foreign_key: "decidim_amendable_id", foreign_type: "decidim_amendable_type", polymorphic: true
    belongs_to :amender, foreign_key: "decidim_user_id", class_name: "Decidim::User"
    belongs_to :emendation, foreign_key: "decidim_emendation_id", foreign_type: "decidim_emendation_type", polymorphic: true

    validates :amendable, :amender, :emendation, presence: true
    validates :state, presence: true, inclusion: { in: STATES }

    def draft?
      state == "draft"
    end

    def evaluating?
      state == "evaluating"
    end

    def rejected?
      state == "rejected"
    end

    def promoted?
      return false unless rejected?

      emendation.linked_promoted_resource.present?
    end

    # VisibilityStepSetting::options can be expanded via config setting.
    #
    # For new options, add the missing locales in `decidim-core/config/locales/en.yml` and
    # change the logic of the filtering methods in the Amendable concern to fit your needs:
    # - Decidim::Amendable::only_visible_emendations_for(user, component)
    # - Decidim::Amendable::amendables_and_visible_emendations_for(user, component)
    # - Decidim::Amendable#visible_emendations_for(user)
    #
    # Returns an Array of Arrays of translation, value:
    # i.e. [["All amendments are visible", "all"], ...]
    class VisibilityStepSetting
      def self.options
        Decidim.config.amendments_visibility_options.map do |option|
          [I18n.t(option, scope: "decidim.amendments.visibility_options"), option]
        end
      end
    end
  end
end
