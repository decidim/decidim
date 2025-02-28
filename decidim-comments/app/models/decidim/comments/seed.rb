# frozen_string_literal: true

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

          rand(0..6).times do
            comment1 = create_comment(resource)
            NewCommentNotificationCreator.new(comment1, []).create

            if [true, false].sample
              comment2 = create_comment(comment1, resource)
              NewCommentNotificationCreator.new(comment2, []).create
            end

            next if [true, false].sample

            create_votes(comment1) if comment1
            create_votes(comment2) if comment2
          end
        end

        private

        attr_reader :organization

        # Creates a comment for a given resource.
        #
        # @private
        #
        # @param resource [Object] - the Decidim resource to add the comments to.
        # @param root_commentable - the root commentable resource. It is optional, used for making nested comments.
        #
        # @return [Decidim::Comments::Comment]
        def create_comment(resource, root_commentable = nil)
          author = rand(2).positive? ? random_user : random_user_group

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
        # The votes can be from a user or a user group.
        #
        # @private
        #
        # @param [Decidim::Comments::Comment]
        #
        # @return nil
        def create_votes(comment)
          rand(0..12).times do
            author = rand(2).positive? ? random_user : random_user_group
            next if CommentVote.where(comment:, author:).any?

            CommentVote.create!(comment:, author:, weight: [1, -1].sample)
          end

          nil
        rescue ActiveRecord::AssociationTypeMismatch
          nil # in case there is a mismatch, we ignore the error as it is not important for the seeding
        end

        def random_user
          user = Decidim::User.not_user_group.where(organization:).not_deleted.not_blocked.confirmed.sample

          user.valid? ? user : random_user
        end

        def random_user_group
          user_group = Decidim::User.user_group.where(organization:).not_deleted.not_blocked.confirmed.verified.sample
          return user_group if user_group&.valid?

          random_user
        end
      end
    end
  end
end
