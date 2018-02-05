# frozen_string_literal: true

module Decidim
  module Log
    # This class holds the logic to present a resource for any activity log.
    # It is supposed to be a base class for all other log renderers, as it defines
    # some helpful methods that later presenters can use.
    #
    # Most presenters that inherit fromt his class will only need to overwrite
    # the `action_string` method, which defines what I18n key will be used for
    # each action.
    #
    # See `Decidim::ActionLog#render_log` for more info on the log types and
    # presenters.
    #
    # Usage should be automatic and you shouldn't need to call this class
    # directly, but here's an example:
    #
    #    action_log = Decidim::ActionLog.last
    #    view_helpers # => this comes from the views
    #    BasePresenter.new(action_log, view_helpers).present
    class BasePresenter
      # Public: Initializes the presenter.
      #
      # action_log - An instance of Decidim::ActionLog.last
      # view_helpers - An object holding the view helpers at the render time.
      #   Most probably should come automatically from the views.
      def initialize(action_log, view_helpers)
        @action_log = action_log
        @view_helpers = view_helpers
      end

      # Public: Renders the resource associated to the given `action_log`.
      #
      # action_log - An instance of Decidim::ActionLog.last
      # view_helpers - An object holding the view helpers at the render time.
      #   Most probably should come automatically from the views.
      #
      # Returns an HTML-safe String.
      def present
        h.content_tag(:li) do
          I18n.t(
            action_string,
            i18n_params
          ).html_safe +
            " (#{h.localize(action_log.created_at, format: :decidim_short)})"
        end
      end

      private

      attr_reader :action_log, :view_helpers
      alias h view_helpers

      delegate :action, to: :action_log

      # Private: Caches the relation. If we `delegate` the relation directly
      # (without caching it at the Ruby level), then we get a lot of `CACHE`
      # queries in the logs, so this reduces the noise.
      #
      # Returns the Decidim::User that performed the action.
      def user
        @user ||= action_log.user
      end

      # Private: Caches the relation. If we `delegate` the relation directly
      # (without caching it at the Ruby level), then we get a lot of `CACHE`
      # queries in the logs, so this reduces the noise.
      #
      # Returns the resource on which the action was performed.
      def resource
        @resource ||= action_log.resource
      end

      # Private: Caches the relation. If we `delegate` the relation directly
      # (without caching it at the Ruby level), then we get a lot of `CACHE`
      # queries in the logs, so this reduces the noise.
      #
      # Returns the Decidim::Feature of the resource, if any.
      def feature
        @feature ||= action_log.feature
      end

      # Private: Caches the relation. If we `delegate` the relation directly
      # (without caching it at the Ruby level), then we get a lot of `CACHE`
      # queries in the logs, so this reduces the noise.
      #
      # Returns the participatory space (Decidim::Participable) of the
      # resource, if any.
      def participatory_space
        @participatory_space ||= action_log.participatory_space
      end

      # Private: Presents a space. If the space is found in the database, it
      # links to it. Otherwise it only shows the name.
      #
      # Returns an HTML-safe String.
      def present_space
        return present_space_name if participatory_space.blank?

        h.link_to(present_space_name, space_path)
      end

      # Private: Presents the resource of the action. If the resource and the
      # space are found in the database, it links to it. Otherwise it only
      # shows the resource name.
      #
      # Returns an HTML-safe String.
      def present_resource
        return present_resource_name if resource.blank? || resource_path.blank?
        return present_resource_name if resource_path.blank?

        h.link_to(present_resource_name, resource_path)
      end

      # Private: Finds the link for the given space.
      #
      # Returns an HTML-safe String.
      def space_path
        Decidim::ResourceLocatorPresenter.new(participatory_space).path
      end

      # Private: Finds the link for the given resource.
      #
      # Returns an HTML-safe String. If the resource space is not
      # present, it returns `nil`.
      def resource_path
        @resource_path ||= begin
                             Decidim::ResourceLocatorPresenter.new(resource).path
                           rescue NoMethodError
                             nil
                           end
      end

      # Private: Presents a space. If the space is found in the database, it
      # links to it. Otherwise it only shows the name.
      #
      # Returns an HTML-safe String.
      def present_space_name
        h.translated_attribute action_log.extra["participatory_space"]["title"]
      end

      # Private: Presents a space. If the space is found in the database, it
      # links to it. Otherwise it only shows the name.
      #
      # Returns an HTML-safe String.
      def present_resource_name
        h.translated_attribute action_log.extra["resource"]["title"]
      end

      # Private: Presents a space. If the space is found in the database, it
      # links to it. Otherwise it only shows the name.
      #
      # Returns an HTML-safe String.
      def present_user
        return present_user_name if user.blank?
        h.link_to(present_user_name, h.decidim.profile_path(action_log.extra["user"]["nickname"]))
      end

      # Private: Presents a space. If the space is found in the database, it
      # links to it. Otherwise it only shows the name.
      #
      # Returns an HTML-safe String.
      def present_user_name
        name = action_log.extra["user"]["name"]
        nickname = action_log.extra["user"]["nickname"]
        "#{name} @#{nickname}"
      end

      # Private: Finds the name of the I18n key that will be sued for the
      # current log action.
      #
      # Returns a String.
      def action_string
        case action.to_s
        when "create"
          "decidim.log.base_presenter.create"
        when "update"
          "decidim.log.base_presenter.update"
        else
          "decidim.log.base_presenter.unknown_action"
        end
      end

      def i18n_params
        {
          user_name: present_user,
          resource_name: present_resource,
          space_name: present_space
        }
      end
    end
  end
end
