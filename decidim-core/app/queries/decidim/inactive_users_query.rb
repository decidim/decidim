# frozen_string_literal: true

module Decidim
  class InactiveUsersQuery < Decidim::Query
    attr_reader :scope

    def initialize(scope = Decidim::User.not_deleted)
      @scope = scope
    end

    def for_first_warning(cutoff_date)
      scope
        .where("(current_sign_in_at <= :cutoff OR current_sign_in_at IS NULL) AND created_at <= :cutoff", cutoff: cutoff_date)
        .where.not("extended_data ? 'inactivity_notification'")
    end

    def for_last_warning(cutoff_date)
      scope
        .where("(extended_data->'inactivity_notification'->>'notification_type') = 'first'")
        .where("(extended_data->'inactivity_notification'->>'sent_at')::timestamp <= ?", cutoff_date)
        .where("current_sign_in_at IS NULL OR current_sign_in_at <= (extended_data->'inactivity_notification'->>'sent_at')::timestamp")
    end

    def for_removal(cutoff_date)
      scope
        .where("(extended_data->'inactivity_notification'->>'notification_type') = 'second'")
        .where("(extended_data->'inactivity_notification'->>'sent_at')::timestamp <= ?", cutoff_date)
        .where("current_sign_in_at IS NULL OR current_sign_in_at <= (extended_data->'inactivity_notification'->>'sent_at')::timestamp")
    end
  end
end
