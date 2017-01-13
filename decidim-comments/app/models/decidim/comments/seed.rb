module Decidim
  module Comments
    class Seed
      def comments_for(resource)
        rand(1..5).times do
          resource.comments.create(
            body: Faker::Hipster.sentence,
            decidim_author_id: Decidim::User.offset(rand(Decidim::User.count)).first
          )
        end
      end
    end
  end
end
