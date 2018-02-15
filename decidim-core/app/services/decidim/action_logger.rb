# frozen_string_literal: true

module Decidim
  # Use this class to log actions by any user.
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
    # resource_extra - a Hash with resource_extra info to be recorded
    #
    # Returns the newly created `Decidim::ActionLog` resource.
    def self.log(action, user, resource, resource_extra = {})
      new(action, user, resource, resource_extra).log!
    end

    # Public: Initializes the instance.
    #
    # action - a String representing the name of the action
    # user - the Decidim::User that performed the action
    # resource - the resource onn which the action was performed
    # resource_extra - a Hash with resource_extra info to be recorded
    def initialize(action, user, resource, resource_extra = {})
      @action = action
      @user = user
      @resource = resource
      @resource_extra = resource_extra
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
        participatory_space: participatory_space,
        feature: feature,
        extra: extra_data
      )
    end

    private

    attr_reader :action, :user, :resource, :resource_extra

    def organization
      user.organization
    end

    def feature
      resource.feature if resource.respond_to?(:feature)
    end

    def participatory_space
      return feature.participatory_space if feature.respond_to?(:participatory_space)
      resource.participatory_space if resource.respond_to?(:participatory_space)
    end

    def title_for(resource)
      resource.try(:title) || resource.try(:name)
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
        feature: {
          manifest_name: feature.try(:manifest_name),
          title: title_for(feature)
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
