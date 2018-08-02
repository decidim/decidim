# frozen_string_literal: true

module Decidim
  module HashtagsHelper
    # def linkify_hashtags(hashtaggable_content)
    #   regex = Decidim::Hashtag::HASHTAG_REGEX
    #   hashtagged_content = hashtaggable_content.to_s.gsub(regex) do
    #     link_to($&, decidim.hashtag_path(Regexp.last_match[2]), class: :hashtag)
    #   end
    #   hashtagged_content.html_safe
    # end

    def render_hashtaggable(hashtaggable)
      klass = hashtaggable.class.to_s.underscore
      partial = klass.split("/").last
      case partial
      when "proposal"
        resource_link = decidim_participatory_process_proposals.proposal_path(participatory_process_slug: hashtaggable.feature.participatory_space.slug, feature_id: hashtaggable.feature.id, id: hashtaggable.id)
      when "result"
        resource_link = ""
      end
      render "card", resource: hashtaggable, resource_link: resource_link
      # render "#{klass.pluralize.to_s}/#{partial.to_s}", resource: hashtaggable, hashtaggable_link:
    end

    def content_renderer(content)
      renderer = Decidim::ContentRenderers::HashtagRenderer.new(content)
      renderer.render.html_safe
    end

    def content_title_renderer(content)
      renderer = Decidim::ContentRenderers::HashtagRenderer.new(content)
      renderer.render_without_link.html_safe
    end
  end
end
