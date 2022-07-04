# frozen_string_literal: true

module Decidim
  class RedesignedProfileCell < Decidim::ViewModel
    include Decidim::ApplicationHelper
    include Decidim::Core::Engine.routes.url_helpers
    include Decidim::UserProfileHelper
    include Decidim::AriaSelectedLinkToHelper
    include Decidim::LayoutHelper
    include ActiveLinkTo

    delegate :current_organization, :current_user, :user_groups_enabled?, to: :controller

    TABS_ITEMS = {
      activity: { icon: "bubble-chart-line", path: :profile_activity_path },
      badges: { icon: "award-line", path: :profile_badges_path },
      following: { icon: "user-received-line", path: :profile_following_path },
      followers: { icon: "user-received-line", path: :profile_followers_path },
      groups: { icon: "team-line", path: :profile_groups_path },
      members: { icon: "contacts-line", path: :profile_members_path },
      conversations: { icon: "question-answer-line", path: :profile_conversations_path }
    }.freeze

    def show
      return render :invalid if profile_holder.blank?
      return render :inaccessible if profile_holder.blocked? && current_user_logged_in?

      render :show
    end

    def profile_holder
      model
    end

    def content_cell
      context[:content_cell]
    end

    def active_content
      context[:active_content]
    end

    def current_user_logged_in?
      current_user && !current_user.admin?
    end

    def own_profile?
      current_user && current_user == profile_holder
    end

    def manageable_group?
      return false unless profile_holder.is_a?(Decidim::UserGroup)

      current_user && current_user.manageable_user_groups.include?(profile_holder)
    end

    def tab_item(key)
      values = TABS_ITEMS[key].dup
      values[:path] = send(values[:path], nickname: profile_holder.nickname)
      values[:text] = t(key, scope: "decidim.profiles.show")
      values
    end

    def user_tabs
      items = [:activity].tap do |keys|
        keys << :badges if current_organization.badges_enabled?
        keys.append(:following, :followers)
        keys << :groups if user_groups_enabled?
      end
      items.map { |key| tab_item(key) }
    end

    def group_tabs
      items = [:members].tap do |keys|
        keys.append(:badges, :followers)
        keys << :conversations if manageable_group?
      end
      items.map { |key| tab_item(key) }
    end

    def tab_items
      profile_holder.is_a?(Decidim::UserGroup) ? group_tabs : user_tabs
    end
  end
end
