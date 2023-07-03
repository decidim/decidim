# frozen_string_literal: true

module Decidim
  module Blogs
    # This cell renders the card for an instance of a Post
    # the default size is the Medium Card (:m)
    class PostCell < Decidim::ViewModel
      def show
        cell card_size, model, options
      end

      private

      # REDESIGN_PENDING: size :m is deprecated
      def card_size
        case @options[:size]
        when :m
          "decidim/blogs/post_m"
        when :s
          "decidim/blogs/post_s"
        when :g
          "decidim/blogs/post_g"
        else
          "decidim/blogs/post_l"
        end
      end
    end
  end
end
