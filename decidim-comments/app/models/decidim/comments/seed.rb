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
        # @param resource [Object] - the Decidim resource to add the coments to.
        #                            examples: Decidim::Proposals::CollaborativeDraft, Decidim::Proposals::Proposal,
        #
        # @return nil
        def comments_for(resource)
          return unless resource.accepts_new_comments?

          Decidim::Comments::Comment.reset_column_information

          rand(0..6).times do
            comment = create_comment(resource)
            create_comment(comment, resource) if [true, false].sample
          end
        end

        private

        # Creates a comment for a given resource.
        #
        # @private
        #
        # @param resource [Object] - the Decidim resource to add the coments to.
        #                            examples: Decidim::Proposals::CollaborativeDraft, Decidim::Proposals::Proposal,
        # @param root_commentable [Decidim::Comments::Comment|nil] - the root commentable resource. It is optional, used for making nested comments.
        #
        # @return [Decidim::Comments::Comment]
        def create_comment(resource, root_commentable = nil)
          author = Decidim::User.where(organization: resource.organization).all.sample
          user_group = [true, false].sample ? Decidim::UserGroups::ManageableUserGroups.for(author).verified.sample : nil

          params = {
            commentable: resource,
            root_commentable: root_commentable || resource,
            body: { en: ::Faker::Lorem.sentence(word_count: 50) },
            author:,
            user_group:
          }

          Decidim.traceability.create!(
            Decidim::Comments::Comment,
            author,
            params,
            visibility: "public-only"
          )
        end
      end
    end
  end
end
