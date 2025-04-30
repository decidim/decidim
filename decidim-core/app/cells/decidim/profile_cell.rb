# frozen_string_literal: true

module Decidim
  class ProfileCell < Decidim::ViewModel
    include Decidim::Core::Engine.routes.url_helpers
    include Decidim::UserProfileHelper
    include Decidim::AriaSelectedLinkToHelper
    include Decidim::ViewHooksHelper
    include ActiveLinkTo

    delegate :current_organization, :current_user, to: :controller
    delegate :avatar_url, :nickname, :personal_url, :followers_count, :users_followings, :officialized_as, to: :presented_profile

    TABS_ITEMS = {
      activity: { icon: "bubble-chart-line", path: :profile_activity_path },
      badges: { icon: "award-line", path: :profile_badges_path },
      following: { icon: "eye-2-line", path: :profile_following_path },
      followers: { icon: "group-line", path: :profile_followers_path }
    }.freeze

    def show
      return render :invalid if profile_holder.blank?
      return render :inaccessible if profile_holder.blocked? && current_user_logged_in?

      render :show
    end

    def profile_holder
      model
    end

    private

    def presented_profile
      present(profile_holder)
    end

    def show_badge?
      profile_holder.officialized?
    end

    def officialization_text
      translated_attribute(officialized_as).presence || t("decidim.profiles.show.officialized")
    end

    def details_items
      [{ icon: "account-pin-circle-line", text: nickname }].tap do |items|
        items.append(icon: "link", text: personal_url, url: personal_url) if personal_url.present?
        if (following_count = users_followings.size).positive?
          items.append(icon: TABS_ITEMS[:following][:icon], text: t("decidim.following.following_count", count: following_count))
        end
        items.append(icon: TABS_ITEMS[:followers][:icon], text: t("decidim.followers.followers_count", count: followers_count)) if profile_holder.followers_count.positive?
      end
    end

    def description
      decidim_html_escape presented_profile.about.to_s
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

    # i18n-tasks-use t("decidim.profiles.show.following")
    # i18n-tasks-use t("decidim.profiles.show.followers")
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
      end
      items.map { |key| tab_item(key) }
    end
  end
end
