# frozen_string_literal: true

module Decidim
  module Comments
    class CommentCreatedEvent < Decidim::Events::SimpleEvent
      include Decidim::Comments::CommentEvent
    end
  end
end
