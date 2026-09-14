# frozen_string_literal: true

require "decidim/seeds"

module Decidim
  module Comments
    # A comment can belong to many Commentable models. This class is responsible
    # to Seed those models in order to be able to use them in the development
    # app.
    class Seed
      class << self
        # Adds a random amount of comments for a given resource.
        #
        # @param resource [Object] - the Decidim resource to add the comments to.
        #                            examples: Decidim::Proposals::Proposal
        #
        # @return nil
        def comments_for(resource)
          return unless resource.accepts_new_comments?

          Decidim::Comments::Comment.reset_column_information

          @organization = resource.organization

          config_value(:comments_per_resource_count).times do
            generate_child_comment = rand < config_value(:comments_nested_probability)
            comment1 = create_comment(resource, comments_count: generate_child_comment ? 1 : 0)
            NewCommentNotificationCreator.new(comment1, []).create

            if generate_child_comment
              comment2 = create_comment(comment1, resource)
              NewCommentNotificationCreator.new(comment2, []).create
            end

            next if rand < config_value(:comments_vote_skip_probability)

            create_votes(comment1) if comment1
            create_votes(comment2) if comment2
          end
          resource.update_comments_count
        end

        private

        attr_reader :organization

        def config_value(key)
          value = slow_seeds? ? Decidim::Seeds::SEEDS_CONFIG[key][:slow] : Decidim::Seeds::SEEDS_CONFIG[key][:fast]
          return rand(value) if value.is_a?(Range)

          value
        end

        def slow_seeds?
          Decidim::Env.new("SLOW_SEEDS").present?
        end

        # Creates a comment for a given resource.
        #
        # @private
        #
        # @param resource [Object] - the Decidim resource to add the comments to.
        # @param root_commentable [Object, Decidim::Comments::Comment] - the root commentable resource. It is optional, used for making nested comments.
        # @param comments_count [Integer] - the amount of nested comments to be created for this record (optional).
        #
        # @return [Decidim::Comments::Comment]
        def create_comment(resource, root_commentable = nil, comments_count: 0)
          author = random_user

          params = {
            commentable: resource,
            root_commentable: root_commentable || resource,
            body: { en: ::Faker::Lorem.sentence(word_count: 50) },
            author:,
            depth: root_commentable.is_a?(Decidim::Comments::Comment) ? 1 : 0,
            comments_count:
          }

          Decidim.traceability.perform_action!(
            "create",
            Decidim::Comments::Comment,
            author,
            visibility: "public-only"
          ) do
            comment = Decidim::Comments::Comment.new(params)
            comment.save!(validate: false)
            comment
          end
        end

        # Creates a random amount of votes for a given comment.
        #
        # @private
        #
        # @param comment [Decidim::Comments::Comment]
        #
        # @return nil
        def create_votes(comment)
          voting_author_ids = CommentVote.where(comment:).pluck(:decidim_author_id)
          author_ids = random_users.where.not(id: voting_author_ids).sample(config_value(:comments_votes_per_comment_count)).pluck(:id)

          # rubocop:disable-next Rails/SkipsModelValidations
          CommentVote.insert_all(
            author_ids.map do |author_id|
              {
                decidim_comment_id: comment.id,
                decidim_author_type: "Decidim::UserBaseEntity",
                decidim_author_id: author_id,
                weight: [1, -1].sample
              }
            end
          )

          up_votes_count = CommentVote.where(decidim_comment_id: comment, weight: 1).count
          down_votes_count = CommentVote.where(decidim_comment_id: comment.id, weight: -1).count
          comment.update(up_votes_count:, down_votes_count:)

          nil
        rescue ActiveRecord::AssociationTypeMismatch
          nil # in case there is a mismatch, we ignore the error as it is not important for the seeding
        end

        def random_users
          @random_users ||= Decidim::User.where(organization:).not_deleted.not_blocked.confirmed
        end

        def random_user
          user = random_users.sample

          user.valid? ? user : random_user
        end
      end
    end
  end
end
