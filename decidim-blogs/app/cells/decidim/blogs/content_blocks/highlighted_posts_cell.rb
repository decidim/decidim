# frozen_string_literal: true

module Decidim
  module Blogs
    module ContentBlocks
      class HighlightedPostsCell < Decidim::ContentBlocks::HighlightedElementsCell
        include Decidim::ComponentPathHelper
        include Decidim::CardHelper

        def show
          render unless posts_count.zero?
        end

        private

        def posts
          @posts ||= Decidim::Blogs::Post.published.where(component: published_components).created_at_desc
        end

        def decidim_blogs
          return unless single_component

          Decidim::EngineRouter.main_proxy(single_component)
        end

        def single_component
          @single_component ||= published_components.one? ? published_components.first : nil
        end

        def posts_to_render
          @posts_to_render ||= posts.includes([:author, :component]).limit(limit)
        end

        def posts_count
          @posts_count ||= posts.size
        end

        def cache_hash
          hash = []
          hash << "decidim/blogs/content_blocks/highlighted_posts"
          hash << posts.cache_key_with_version
          hash << I18n.locale.to_s
          hash.join(Decidim.cache_key_separator)
        end

        def limit
          3
        end
      end
    end
  end
end
