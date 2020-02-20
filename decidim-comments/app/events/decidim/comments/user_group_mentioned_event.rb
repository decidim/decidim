# frozen-string_literal: true

module Decidim
  module Comments
    class UserGroupMentionedEvent < Decidim::Events::SimpleEvent
      include Decidim::Comments::CommentEvent
      include Decidim::Events::GroupEvent
    end
  end
end
