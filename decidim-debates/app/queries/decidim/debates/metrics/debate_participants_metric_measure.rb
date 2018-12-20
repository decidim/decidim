# frozen_string_literal: true

module Decidim
  module Debates
    module Metrics
      # Searches for Participants in the following actions
      #  - Create a debate (Debates)
      class DebateParticipantsMetricMeasure < Decidim::MetricMeasure
        def valid?
          super && @resource.is_a?(Decidim::Component)
        end

        def calculate
          debates = Decidim::Debates::Debate.where(component: @resource).joins(:component)
                                            .where("decidim_debates_debates.created_at <= ?", end_time)
                                            .where(decidim_author_type: Decidim::UserBaseEntity.name)
                                            .where.not(author: nil)

          {
            cumulative_users: debates.pluck(:decidim_author_id),
            quantity_users: debates.where("decidim_debates_debates.created_at >= ?", start_time).pluck(:decidim_author_id)
          }
        end
      end
    end
  end
end
