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

        rand(1..5).times do
          random = rand(Decidim::User.count)
          Comment.create(
            commentable: resource,
            body: Faker::Lorem.sentence,
            author: Decidim::User.where(organization: organization).offset(random).first
          )
        end
      end
    end
  end
end
