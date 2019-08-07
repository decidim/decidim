# frozen-string_literal: true

module Decidim
  module Comments
    class ReplyCreatedEvent < Decidim::Events::SimpleEvent
      include Decidim::Comments::CommentEvent
    end
  end
end
