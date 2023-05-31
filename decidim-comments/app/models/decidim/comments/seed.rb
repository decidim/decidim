# frozen_string_literal: true

module Decidim
  module Comments
    # A comment can belong to many Commentable models. This class is responsible
    # to Seed those models in order to be able to use them in the development
    # app.
    class Seed
      # Public: adds a random amount of comments for a given resource.
      #
      # resource - the resource to add the coments to.
      #
      # Returns nothing.
      def self.comments_for(resource)
        return unless resource.accepts_new_comments?

        Decidim::Comments::Comment.reset_column_information

        organization = resource.organization

        2.times do
          author = Decidim::User.where(organization:).all.sample
          user_group = [true, false].sample ? Decidim::UserGroups::ManageableUserGroups.for(author).verified.sample : nil

          params = {
            commentable: resource,
            root_commentable: resource,
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
