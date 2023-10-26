# frozen_string_literal: true

module Decidim
  module Comments
    # A comment can belong to many Commentable models. This class is responsible
    # to Seed those models in order to be able to use them in the development
    # app.
    class Seed
      class << self
        # Public: adds a random amount of comments for a given resource.
        #
        # resource - the resource to add the coments to.
        #
        # Returns nothing.
        def comments_for(resource)
          return unless resource.accepts_new_comments?

          Decidim::Comments::Comment.reset_column_information

          rand(0..6).times do
            comment = create_comment(resource)
            create_comment(comment, resource) if [true, false].sample
          end
        end

        private

        # Private - creates a comment for a given resource.
        #
        # resource - the resource to add the coments to.
        # root_commentable - the root commentable resource. It's optional, used for making nested comments.
        #
        # Returns the created comment.
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
