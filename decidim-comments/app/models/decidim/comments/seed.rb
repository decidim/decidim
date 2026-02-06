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
        #                            examples: Decidim::Proposals::CollaborativeDraft, Decidim::Proposals::Proposal,
        #
        # @return nil
        def comments_for(resource)
          return unless resource.accepts_new_comments?

          Decidim::Comments::Comment.reset_column_information

          @organization = resource.organization

          rand(0..config_value(:comments_count)).times do
            comment1 = create_comment(resource)
            NewCommentNotificationCreator.new(comment1, []).create

            if rand < config_value(:comments_nested_probability)
              comment2 = create_comment(comment1, resource)
              NewCommentNotificationCreator.new(comment2, []).create
            end

            next if rand < config_value(:comments_vote_skip_probability)

            create_votes(comment1) if comment1
            create_votes(comment2) if comment2
          end
        end

        private

        attr_reader :organization

        def config_value(key)
          slow_seeds? ? Decidim::Seeds::SEEDS_CONFIG[key][:slow] : Decidim::Seeds::SEEDS_CONFIG[key][:fast]
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
        #
        # @return [Decidim::Comments::Comment]
        def create_comment(resource, root_commentable = nil)
          author = random_user

          params = {
            commentable: resource,
            root_commentable: root_commentable || resource,
            body: { en: ::Faker::Lorem.sentence(word_count: 50) },
            author:
          }

          Decidim.traceability.create!(
            Decidim::Comments::Comment,
            author,
            params,
            visibility: "public-only"
          )
        end

        # Creates a random amount of votes for a given comment.
        #
        # @private
        #
        # @param comment [Decidim::Comments::Comment]
        #
        # @return nil
        def create_votes(comment)
          rand(0..config_value(:comments_votes_count)).times do
            author = random_user
            next if CommentVote.where(comment:, author:).any?

            CommentVote.create!(comment:, author:, weight: [1, -1].sample)
          end

          nil
        rescue ActiveRecord::AssociationTypeMismatch
          nil # in case there is a mismatch, we ignore the error as it is not important for the seeding
        end

        def random_user
          user = Decidim::User.where(organization:).not_deleted.not_blocked.confirmed.sample

          user.valid? ? user : random_user
        end
      end
    end
  end
end
