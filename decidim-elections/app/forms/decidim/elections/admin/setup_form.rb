# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # This class holds a Form to create/update elections from Decidim's admin panel.
      class SetupForm < Decidim::Form
        validates :start_time, presence: true, date: { before: :end_time }
        validates :end_time, presence: true, date: { after: :start_time }
        validate :allow_if_valid_for_setup

        private

        def allow_if_valid_for_setup
          errors.add(:started, :cannot_be_started) if election.started?
          # !election.questions.empty? && election.minimum_answers? && election.minimum_three_hours_before_start? &&
          #              election.published_at.present?
          # trustees
        end

        def trustees
          @trustees ||= Decidim::Elections::Trustee.find_by(trustees_participatory_spaces: current_participatory_space, considered: true)
        end
      end
    end
  end
end
