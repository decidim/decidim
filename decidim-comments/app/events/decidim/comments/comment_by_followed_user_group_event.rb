# frozen-string_literal: true

module Decidim
  module Comments
    class CommentByFollowedUserGroupEvent < Decidim::Events::SimpleEvent
      include Decidim::Comments::CommentEvent
    end
  end
end
