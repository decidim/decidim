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
    # params - a Hash
    #
    # Returns an instance of `klass`.
    def create(klass, author, params)
      PaperTrail.whodunnit(gid(author)) do
        klass.transaction do
          resource = klass.create(params)
          log(:create, author, resource)
          resource
        end
      end
    end

    # Calls the `create!` method to the given class and sets the author of the version.
    #
    # klass - An ActiveRecord class that implements `Decidim::Traceable`
    # author - An object that implements `to_gid` or a String
    # params - a Hash
    #
    # Returns an instance of `klass`.
    def create!(klass, author, params)
      PaperTrail.whodunnit(gid(author)) do
        klass.transaction do
          resource = klass.create!(params)
          log(:create, author, resource)
          resource
        end
      end
    end

    # Updates the `resource` with `update_attributes!` and sets the author of the version.
    #
    # resource - An ActiveRecord instance that implements `Decidim::Traceable`
    # author - An object that implements `to_gid` or a String
    # params - a Hash
    #
    # Returns the updated `resource`.
    def update!(resource, author, params)
      PaperTrail.whodunnit(gid(author)) do
        resource.class.transaction do
          resource.update_attributes!(params)
          log(:update, author, resource)
          resource
        end
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

    def log(action, user, resource)
      return unless user.is_a?(Decidim::User)
      return unless resource.is_a?(Decidim::Traceable)

      Decidim::ActionLogger.log(
        action,
        user,
        resource,
        version_params(resource)
      )
    end

    def version_params(resource)
      return {} unless resource.is_a?(Decidim::Traceable)
      return {} if resource.versions.blank?

      {
        version: {
          number: resource.versions.count,
          id: resource.versions.last.id
        }
      }
    end
  end
end
