# frozen_string_literal: true

module Decidim
  module ContentBlocks
    # A cell to be rendered as a content block with the latest activities performed
    # in a Decidim Organization.
    class MenuBreadcrumbLastActivityCell < LastActivityCell
      private

      # A MD5 hash of model attributes because is needed because
      # it ensures the cache version value will always be the same size
      def cache_hash
        hash = []
        hash << "decidim/content_blocks/menu_breadcrumb_last_activity"
        hash << Digest::MD5.hexdigest(valid_activities.map(&:cache_key_with_version).to_s)
        hash << I18n.locale.to_s

        hash.join(Decidim.cache_key_separator)
      end

      def activities_options
        @activities_options ||= { id_prefix: "menu-breadcrumb" }.merge(options.slice(:show_participatory_space))
      end

      def activities_to_show
        4
      end
    end
  end
end
