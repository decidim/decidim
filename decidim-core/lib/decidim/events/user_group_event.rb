# frozen_string_literal: true

module Decidim
  module Events
    # This module is used to be included in event classes inheriting from SimpleEvent
    # whose resource has an in the "extra" options a user_group in the keyword :group.
    #
    # It adds the group_name, group_nickname, group_path and group_url to the i18n interpolations.
    module UserGroupEvent
      extend ActiveSupport::Concern

      included do
        i18n_attributes :group_name, :group_nickname, :group_path, :group_url

        def group_nickname
          group_presenter&.nickname.to_s
        end

        def group_name
          group_presenter&.name.to_s
        end

        def group_path
          group_presenter&.profile_path.to_s
        end

        def group_url
          group_presenter&.profile_url.to_s
        end

        def group_presenter
          return unless group

          @group_presenter ||= Decidim::UserGroupPresenter.new(group)
        end

        def group
          @group ||= fetch_group
        end

        private

        def fetch_group
          return extra[:group] if extra[:group].is_a?(Decidim::UserGroup)

          Decidim::UserGroup.find_by(id: extra[:group_id]) if extra[:group_id]
        end
      end
    end
  end
end
