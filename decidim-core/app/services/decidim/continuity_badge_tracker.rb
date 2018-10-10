# frozen_string_literal: true

module Decidim
  # This class keeps tabs on a user's consecutive days streak
  # so it can update the score of their continuity badge.
  class ContinuityBadgeTracker
    # Initializes the class with a polymorphic subject
    #
    # subject - A in instance of a subclass of ActiveRecord::Base to be tracked
    #
    def initialize(subject)
      @subject = subject
    end

    # Public: Tracks the past activity of a user to update the continuity badge's
    # score. It will set it to the amount of consecutive days a user has logged into
    # the system.
    #
    # date - The date of the last user's activity. Usually `Time.zone.today`.
    #
    # Returns nothing.
    def track!(date)
      @subject.with_lock do
        last_session_at = status.try(:last_session_at) || date
        current_streak = status.try(:current_streak) || 1

        streak = if last_session_at == date
                   current_streak
                 elsif last_session_at == date - 1.day
                   current_streak + 1
                 else
                   1
                 end

        update_status(date, streak)
        update_badge(streak)
      end
    end

    private

    def update_badge(streak)
      score = Decidim::Gamification.status_for(@subject, :continuity).score
      return unless streak > 1 && streak > score

      Decidim::Gamification.set_score(@subject, :continuity, streak)
    end

    def status
      @status ||= ContinuityBadgeStatus.find_by(
        subject: @subject
      )
    end

    def update_status(date, streak)
      @status = ContinuityBadgeStatus.find_or_initialize_by(
        subject: @subject
      ).update(
        last_session_at: date,
        current_streak: streak
      )
    end
  end
end
