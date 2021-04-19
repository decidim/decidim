# frozen_string_literal: true

module Decidim
  module Comments
    module Metrics
      # Searches for Participants in the following actions
      #  - Leave a comment (Comments)
      class CommentParticipantsMetricMeasure < Decidim::MetricMeasure
        def valid?
          super && @resource.is_a?(Decidim::Participable)
        end

        def calculate
          cumulative_users = []
          quantity_users = []

          retrieve_comments_for_organization.each do |comment|
            related_object = comment.root_commentable
            next unless related_object
            next unless check_participatory_space(@resource, related_object)

            cumulative_users << comment.decidim_author_id
            quantity_users << comment.decidim_author_id if comment.created_at >= start_time
          end
          {
            cumulative_users: cumulative_users.uniq,
            quantity_users: quantity_users.uniq
          }
        end

        private

        def check_participatory_space(participatory_space, related_object)
          return related_object.participatory_space == participatory_space if related_object.respond_to?(:participatory_space)
          return related_object == participatory_space if related_object.is_a?(Decidim::Participable)

          false
        end

        def retrieve_comments_for_organization
          user_ids = Decidim::User.where(organization: @resource.organization).pluck(:id)
          Decidim::Comments::Comment.includes(:root_commentable).not_hidden
                                    .where("decidim_comments_comments.created_at <= ?", end_time)
                                    .where(decidim_comments_comments: { decidim_author_id: user_ids })
                                    .where(decidim_comments_comments: { decidim_author_type: "Decidim::UserBaseEntity" })
        end
      end
    end
  end
end
