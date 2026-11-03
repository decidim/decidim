# frozen_string_literal: true

module Decidim
  # Use this class to log actions by any user. You probably should not
  # use this class directly, but rather use `Decidim.traceability` instead.
  # Check the docs on `Decidim::Traceability` for more info.
  #
  # @example Log an action performed by a user
  #   Decidim::ActionLogger.log(:create, user, new_proposal, version_id, extra_data)
  #
  # @example Log an action performed by the system
  #   Decidim::ActionLogger.log_system(:create, new_proposal, visibility: "public-only")
  #
  # @see Decidim::Traceability
  class ActionLogger
    # Logs the given `action` by the given `user` on the given `resource`.
    # Delegates the work to the instance method.
    #
    # @param action [String, Symbol] the name of the action performed
    # @param user [Decidim::User, Decidim::Api::ApiUser] the user that
    #   performed the action
    # @param resource [ActiveRecord::Base] the resource on which the action was
    #   performed
    # @param version_id [Integer, nil] the ID of the `PaperTrail::Version` that
    #   was created by the action
    # @param resource_extra [Hash] extra information to be recorded in the
    #   action log. It may include the `:visibility` key to set the visibility
    #   of the action log.
    #
    # @return [Decidim::ActionLog] the newly created action log
    #
    # @raise [ArgumentError] if `user` is `nil`. Use {.log_system} for actions
    #   performed by the system.
    def self.log(action, user, resource, version_id, resource_extra = {})
      raise ArgumentError, "ActionLogger.log requires a user. Use ActionLogger.log_system for actions performed by the system." if user.nil?

      new(action, user, resource, version_id, resource_extra).send(:log!)
    end

    # Logs the given `action` performed by the system (i.e. without a user) on
    # the given `resource`.
    #
    # @param action [String, Symbol] the name of the action performed
    # @param resource [ActiveRecord::Base] the resource on which the action was
    #   performed
    # @param resource_extra [Hash] keyword arguments with extra information to
    #   be recorded in the action log. It may include the `:visibility` key to
    #   set the visibility of the action log.
    #
    # @return [Decidim::ActionLog] the newly created action log
    def self.log_system(action, resource, **resource_extra)
      new(action, nil, resource, nil, resource_extra).send(:log!)
    end

    # Initializes the instance.
    #
    # @param action [String, Symbol] the name of the action performed
    # @param user [Decidim::User, Decidim::Api::ApiUser, nil] the user that
    #   performed the action, or `nil` for actions performed by the system
    # @param resource [ActiveRecord::Base] the resource on which the action was
    #   performed
    # @param version_id [Integer, nil] the ID of the `PaperTrail::Version` that
    #   was created by the action
    # @param resource_extra [Hash] extra information to be recorded in the
    #   action log. It may include the `:visibility` key to set the visibility
    #   of the action log, which defaults to `"admin-only"`.
    def initialize(action, user, resource, version_id = nil, resource_extra = {})
      @action = action
      @user = user
      @resource = resource
      @version_id = version_id
      @resource_extra = resource_extra
      @visibility = resource_extra.delete(:visibility).presence || "admin-only"
    end

    private

    # Logs the given `action` by the given `user` on the given `resource`.
    #
    # @return [Decidim::ActionLog] the newly created action log
    #
    # @raise [ActiveRecord::RecordInvalid] if the action log is not valid
    def log!
      Decidim::ActionLog.create!(
        user_id: user&.id,
        user_type: user&.class&.name,
        organization:,
        action:,
        resource:,
        resource_id: resource.id,
        resource_type: resource.class.name,
        participatory_space:,
        component:,
        area:,
        scope:,
        version_id:,
        extra: extra_data,
        visibility:
      )
    end

    # The values given to the logger when it was initialized.
    attr_reader :action, :user, :resource, :resource_extra, :version_id, :visibility

    # Finds the organization related to the action log.
    #
    # @return [Decidim::Organization, nil] the organization of the user, the
    #   participatory space, or the resource, whichever is found first
    def organization
      user&.organization || participatory_space&.organization || resource.try(:organization)
    end

    # Finds the component related to the resource.
    #
    # @return [Decidim::Component, nil] the component of the resource, if the
    #   resource responds to `component`
    def component
      resource.component if resource.respond_to?(:component)
    end

    # Finds the participatory space related to the resource.
    #
    # @return [ActiveRecord::Base, nil] the participatory space of the
    #   component, of the resource, or `nil` if it cannot be found
    def participatory_space
      return component.participatory_space if component.respond_to?(:participatory_space)

      resource.participatory_space if resource.respond_to?(:participatory_space)
    end

    # Finds the area related to the resource or its participatory space.
    #
    # @return [Decidim::Area, nil] the area of the resource or the
    #   participatory space, or `nil` if it cannot be found
    def area
      resource.try(:area) || participatory_space.try(:area)
    end

    # Finds the scope related to the resource or its participatory space.
    #
    # @return [Decidim::Scope, nil] the scope of the resource or the
    #   participatory space, or `nil` if it cannot be found
    def scope
      resource.try(:scope) || participatory_space.try(:scope)
    end

    # Finds a human-readable title for the given resource.
    #
    # @param resource [Object, nil] an object that may respond to `title`,
    #   `name`, or `subject`
    # @return [String, nil] the title, name, or subject of the resource, or
    #   `nil` if none of them is available
    def title_for(resource)
      resource.try(:title) || resource.try(:name) || resource.try(:subject)
    end

    # Finds the manifest name of the participatory space.
    #
    # @return [Symbol, nil] the manifest name of the participatory space, or
    #   `nil` if it cannot be found
    def participatory_space_manifest_name
      participatory_space.try(:class).try(:participatory_space_manifest).try(:name)
    end

    # Defines some extra data that will be saved in the action log `extra`
    # field.
    #
    # @return [Hash] the extra data with information about the component, the
    #   participatory space, the resource, and the user, merged with the
    #   `resource_extra` information
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
          ip: user&.current_sign_in_ip,
          name: user&.name,
          nickname: user&.nickname
        }.compact
      }.deep_merge(resource_extra)
    end
  end
end
