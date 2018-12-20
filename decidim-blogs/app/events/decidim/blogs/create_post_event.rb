# frozen_string_literal: true

module Decidim
  module Blogs
    class CreatePostEvent < Decidim::Events::SimpleEvent
      def resource_text
        translated_attribute(resource.body)
      end
    end
  end
end
