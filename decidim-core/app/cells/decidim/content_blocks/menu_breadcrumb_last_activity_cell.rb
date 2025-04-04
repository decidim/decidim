# frozen_string_literal: true

module Decidim
  module ContentBlocks
    # A cell to be rendered as a content block with the latest activities performed
    # in a Decidim Organization.
    class MenuBreadcrumbLastActivityCell < LastActivityCell
      def show
        return if current_user.blank? && current_organization&.force_users_to_authenticate_before_access_organization

        super
      end

      private

      def activities
        @activities ||= if model.is_a?(Decidim::Organization)
                          Decidim::LastActivity.new(model).query
                        else
                          Decidim::ParticipatorySpaceLastActivity.new(model).query
                        end.limit(activities_to_show * 6)
      end

      # A MD5 hash of model attributes is needed because
      # it ensures the cache version value will always be the same size
      def cache_hash
        hash = []
        hash << "decidim/content_blocks/menu_breadcrumb_last_activity"
        hash << id_prefix
        hash << Digest::SHA256.hexdigest(valid_activities.map(&:cache_key_with_version).to_s)
        hash << I18n.locale.to_s

        hash.join(Decidim.cache_key_separator)
      end

      def activities_options
        @activities_options ||= { id_prefix: }.merge(options.slice(:hide_participatory_space))
      end

      def id_prefix
        @id_prefix ||= options[:id_prefix] || model.respond_to?(:to_gid) ? model.to_gid.to_param : "menu-breadcrumb"
      end

      def activities_to_show
        4
      end
    end
  end
end
