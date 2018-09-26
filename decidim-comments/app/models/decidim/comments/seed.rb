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
        organization = resource.organization

        2.times do
          author = Decidim::User.where(organization: organization).all.sample
          user_group = [true, false].sample ? author.user_groups.verified.sample : nil

          params = {
            commentable: resource,
            root_commentable: resource,
            body: ::Faker::Lorem.sentence,
            author: author,
            user_group: user_group
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
