# frozen_string_literal: true

module Decidim
  # Use this class to log actions by any user. You probably shouldn't
  # use this class dfirectly, but rather use `Decidim.traceability` instead.
  # Check the docs on `Decidim::Traceability` for more info.
  #
  # Usage:
  #
  #    ActionLogger.log(:create, user, new_proposal, extra_data)
  class ActionLogger
    # Public: Logs the given `action` by the given `user` on the given `resource`.
    # Delegates the work to the instance method.
    #
    # action - a String representing the name of the action
    # user - the Decidim::User that performed the action
    # resource - the resource onn which the action was performed
    # version_id - the ID of the `PaperTrail::Version` that was created on that action
    # resource_extra - a Hash with resource_extra info to be recorded
    #
    # Returns the newly created `Decidim::ActionLog` resource.
    def self.log(action, user, resource, version_id, resource_extra = {})
      new(action, user, resource, version_id, resource_extra).log!
    end

    # Public: Initializes the instance.
    #
    # action - a String representing the name of the action
    # user - the Decidim::User that performed the action
    # resource - the resource onn which the action was performed
    # version_id - the ID of the `PaperTrail::Version` that was created on that action
    # resource_extra - a Hash with resource_extra info to be recorded
    def initialize(action, user, resource, version_id = nil, resource_extra = {})
      @action = action
      @user = user
      @resource = resource
      @version_id = version_id
      @resource_extra = resource_extra
      @visibility = resource_extra.delete(:visibility).presence || "admin-only"
    end

    # Public: Logs the given `action` by the given `user` on the given
    # `resource`.
    #
    # Returns the newly created `Decidim::ActionLog` resource.
    def log!
      Decidim::ActionLog.create!(
        user: user,
        organization: organization,
        action: action,
        resource: resource,
        resource_id: resource.id,
        resource_type: resource.class.name,
        participatory_space: participatory_space,
        component: component,
        version_id: version_id,
        extra: extra_data,
        visibility: visibility
      )
    end

    private

    attr_reader :action, :user, :resource, :resource_extra, :version_id, :visibility

    def organization
      user.organization
    end

    def component
      resource.component if resource.respond_to?(:component)
    end

    def participatory_space
      return component.participatory_space if component.respond_to?(:participatory_space)
      resource.participatory_space if resource.respond_to?(:participatory_space)
    end

    def title_for(resource)
      resource.try(:title) || resource.try(:name) || resource.try(:subject)
    end

    def participatory_space_manifest_name
      participatory_space.try(:class).try(:participatory_space_manifest).try(:name)
    end

    # Private: Defines some extra data that will be saved in the action log `extra`
    # field.
    #
    # Returns a Hash.
    def extra_data
      {
        component: {
          manifest_name: component.try(:manifest_name),
          title: title_for(component)
        }.compact,
        participatory_space: {
          manifest_name: participatory_space_manifest_name,
          title: title_for(participatory_space)
        }.compact,
        resource: {
          title: title_for(resource)
        }.compact,
        user: {
          ip: user.current_sign_in_ip,
          name: user.name,
          nickname: user.nickname
        }.compact
      }.deep_merge(resource_extra)
    end
  end
end
