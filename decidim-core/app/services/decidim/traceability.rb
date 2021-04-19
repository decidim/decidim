# frozen_string_literal: true

module Decidim
  # This class wraps the logic to trace resource changes and their authorship.
  # It is expected to be used with classes implementing the `Decidim::Traceable`
  # concern. Version authors can be retrieved using the methods in
  # `Decidim::TraceabilityHelper`.
  #
  # Examples:
  #
  #     # consider MyResource implements Decidim::Traceable
  #     resource = Decidim::Traceability.new.create!(MyResource, author, params)
  #     resource.versions.count # => 1
  #     resource.versions.last.whodunnit # => author.to_gid.to_s
  #     resource.versions.last.event # => "create"
  #     resource = Decidim::Traceability.new.update!(resource, author, params)
  #     resource.versions.count # => 2
  #     resource.versions.last.event # => "update"
  #
  # This class uses the `paper_trail` gem internally, so refer to its documentation
  # for further info on how to interact with versions.
  class Traceability
    # Calls the `create` method to the given class and sets the author of the version.
    #
    # klass - An ActiveRecord class that implements `Decidim::Traceable`
    # author - An object that implements `to_gid` or a String
    # params - a Hash with the attributes of the new resource
    # extra_log_info - a Hash with extra info that will be saved to the log
    #
    # Returns an instance of `klass`.
    def create(klass, author, params, extra_log_info = {})
      perform_action!(:create, klass, author, extra_log_info) do
        klass.create(params)
      end
    end

    # Calls the `create!` method to the given class and sets the author of the version.
    #
    # klass - An ActiveRecord class that implements `Decidim::Traceable`
    # author - An object that implements `to_gid` or a String
    # params - a Hash with the attributes of the new resource
    # extra_log_info - a Hash with extra info that will be saved to the log
    #
    # Returns an instance of `klass`.
    def create!(klass, author, params, extra_log_info = {})
      perform_action!(:create, klass, author, extra_log_info) do
        klass.create!(params)
      end
    end

    # Performs the given block and sets the author of the action.
    # It also logs the action with the given `action` parameter.
    # The action and the logging are run inside a transaction.
    #
    # action - a String or Symbol representing the action performed
    # resource - An ActiveRecord instance that implements `Decidim::Traceable`
    # author - An object that implements `to_gid` or a String
    # extra_log_info - a Hash with extra info that will be saved to the log
    #
    # Returns whatever the given block returns.
    def perform_action!(action, resource, author, extra_log_info = {})
      PaperTrail.request(whodunnit: gid(author)) do
        Decidim::ApplicationRecord.transaction do
          result = block_given? ? yield : nil
          loggable_resource = resource.is_a?(Class) ? result : resource
          log(action, author, loggable_resource, extra_log_info)
          return result
        end
      end
    end

    # Updates the `resource` with `update!` and sets the author of the version.
    #
    # resource - An ActiveRecord instance that implements `Decidim::Traceable`
    # author - An object that implements `to_gid` or a String
    # params - a Hash with the attributes to update to the resource
    # extra_log_info - a Hash with extra info that will be saved to the log
    #
    # Returns the updated `resource`.
    def update!(resource, author, params, extra_log_info = {})
      perform_action!(:update, resource, author, extra_log_info) do
        resource.update!(params)
        resource
      end
    end

    # Finds the author of the last version of the resource.
    #
    # resource - an object implementing `Decidim::Traceable`
    #
    # Returns an object identifiable via GlobalID or a String.
    def last_editor(resource)
      version_editor(resource.versions.last)
    end

    # Finds the author of the given version.
    #
    # version - an object that responds to `whodunnit` and returns a String.
    #
    # Returns an object identifiable via GlobalID or a String.
    def version_editor(version)
      ::GlobalID::Locator.locate(version.whodunnit) || version.whodunnit
    end

    private

    # Calculates the GlobalID of the version author. If the object does not respond to
    # `to_gid`, then it returns the object itself.
    def gid(author)
      return if author.blank?
      return author.to_gid if author.respond_to?(:to_gid)

      author
    end

    def log(action, user, resource, extra_log_info = {})
      return unless user.is_a?(Decidim::User)
      # If the record is not valid, it may not yet have an ID causing an
      # exception when trying to save the log record.
      return unless resource.valid?

      Decidim::ActionLogger.log(
        action,
        user,
        resource,
        version_id(resource),
        extra_log_info
      )
    end

    def version_id(resource)
      return nil unless resource.is_a?(Decidim::Traceable)
      return nil if resource.versions.blank?

      resource.versions.last.id
    end
  end
end
