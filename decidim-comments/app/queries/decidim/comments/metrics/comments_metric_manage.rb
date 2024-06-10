# frozen_string_literal: true

module Decidim
  module Comments
    module Metrics
      class CommentsMetricManage < Decidim::MetricManage
        def metric_name
          "comments"
        end

        def save
          query.each do |key, results|
            cumulative_value = results[:cumulative]
            next if cumulative_value.zero?

            quantity_value = results[:quantity] || 0
            space_type, space_id, category_id, related_object_type, related_object_id = key
            record = Decidim::Metric.find_or_initialize_by(day: @day.to_s, metric_type: @metric_name,
                                                           participatory_space_type: space_type, participatory_space_id: space_id,
                                                           organization: @organization, decidim_category_id: category_id,
                                                           related_object_type:, related_object_id:)
            record.assign_attributes(cumulative: cumulative_value, quantity: quantity_value)
            record.save!
          end
        end

        private

        # Creates a Hashed structure with comments grouped by
        #
        #  - ParticipatorySpace (type & ID)
        #  - Category (ID)
        #  - RelatedObject (type & ID)
        #
        def query
          return @query if @query

          @query = retrieve_comments.each_with_object({}) do |comment, grouped_comments|
            related_object = comment.root_commentable
            next grouped_comments unless related_object

            group_key = generate_group_key(related_object)
            next grouped_comments unless group_key

            grouped_comments[group_key] ||= { cumulative: 0, quantity: 0 }
            grouped_comments[group_key][:cumulative] += 1
            grouped_comments[group_key][:quantity] += 1 if comment.created_at >= start_time

            grouped_comments
          end

          @query
        end

        # Retrieve Comments generated within an Organization
        #
        # Uses 'author' and 'user_group' relationship
        #
        def retrieve_comments
          user_ids = Decidim::User.select(:id).where(organization: @organization).collect(&:id)
          user_group_ids = Decidim::UserGroup.select(:id).where(organization: @organization).collect(&:id)
          Decidim::Comments::Comment.includes(:root_commentable).not_hidden.not_deleted
                                    .where("decidim_comments_comments.created_at <= ?", end_time)
                                    .where("decidim_comments_comments.decidim_author_id IN (?) OR
                                           decidim_comments_comments.decidim_user_group_id IN (?)", user_ids, user_group_ids)
        end

        # Generates a group key from the related object of a Comment
        def generate_group_key(related_object)
          participatory_space = retrieve_participatory_space(related_object)
          return unless participatory_space

          category_id = related_object.respond_to?(:category) ? related_object.category.try(:id) : ""
          group_key = []
          group_key += [participatory_space.class.name, participatory_space.id]
          group_key += [category_id]
          group_key += [related_object.class.name, related_object.id]
          group_key
        end

        # Gets current ParticipatorySpace of a given 'related_object'
        def retrieve_participatory_space(related_object)
          if related_object.respond_to?(:participatory_space)
            related_object.participatory_space
          elsif related_object.is_a?(Decidim::Participable)
            related_object
          end
        end
      end
    end
  end
end
