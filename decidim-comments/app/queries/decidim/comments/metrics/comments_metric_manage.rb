# frozen_string_literal: true

module Decidim
  module Comments
    module Metrics
      class CommentsMetricManage < Decidim::MetricManage
        def metric_name
          "comments"
        end

        def save
          return @registry if @registry

          @registry = []
          query.each do |key, results|
            cumulative_value = results[:cumulative]
            next if cumulative_value.zero?
            quantity_value = results[:quantity] || 0
            space_type, space_id, category_id, related_object_type, related_object_id = key
            record = Decidim::Metric.find_or_initialize_by(day: @day.to_s, metric_type: @metric_name,
                                                           participatory_space_type: space_type, participatory_space_id: space_id,
                                                           organization: @organization, decidim_category_id: category_id,
                                                           related_object_type: related_object_type, related_object_id: related_object_id)
            record.assign_attributes(cumulative: cumulative_value, quantity: quantity_value)
            @registry << record
          end
          @registry.each(&:save!)
          @registry
        end

        private

        def query
          return @query if @query

          user_ids = Decidim::User.select(:id).where(organization: @organization).collect(&:id)
          user_group_ids = Decidim::UserGroup.select(:id).where(organization: @organization).collect(&:id)
          comments = Decidim::Comments::Comment.includes(:root_commentable).not_hidden
                                               .where("decidim_comments_comments.created_at <= ?", end_time)
                                               .where("decidim_comments_comments.decidim_author_id IN (?) OR
                                                     decidim_comments_comments.decidim_user_group_id IN (?)", user_ids, user_group_ids)

          @query = comments.each_with_object({}) do |comment, query_h|
            root_commentable = comment.root_commentable
            return query_h unless root_commentable
            space_type = ""
            space_id = ""
            category_id = ""
            related_object_type = comment.decidim_root_commentable_type
            related_object_id = comment.decidim_root_commentable_id

            if root_commentable.is_a? Decidim::Participable
              space_type = comment.decidim_root_commentable_type
              space_id = comment.decidim_root_commentable_id
            elsif root_commentable.is_a? Decidim::Component
              space_type = root_commentable.participatory_space_type
              space_id = root_commentable.participatory_space_id
            elsif comment.root_commentable.is_a? Decidim::HasComponent
              space_type = root_commentable.component.participatory_space_type
              space_id = root_commentable.component.participatory_space_id
            end
            category_id = root_commentable.category.try(:id) if root_commentable.respond_to?(:category)

            query_h[[space_type, space_id, category_id, related_object_type, related_object_id]] ||= { cumulative: 0, quantity: 0 }
            query_h[[space_type, space_id, category_id, related_object_type, related_object_id]][:cumulative] += 1
            query_h[[space_type, space_id, category_id, related_object_type, related_object_id]][:quantity] += 1 if comment.created_at >= start_time

            query_h
          end

          @query
        end
      end
    end
  end
end
