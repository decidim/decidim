# frozen_string_literal: true

module Decidim
  # This class represents an action of a user on a resource. It is used
  # for transparency reasons, to log all actions so all other users can
  # see the actions being performed.
  class ActionLog < ApplicationRecord
    include Decidim::ScopableParticipatorySpace

    belongs_to :organization,
               foreign_key: :decidim_organization_id,
               class_name: "Decidim::Organization"

    belongs_to :user,
               foreign_key: :decidim_user_id,
               class_name: "Decidim::User"

    belongs_to :component,
               foreign_key: :decidim_component_id,
               optional: true,
               class_name: "Decidim::Component"

    belongs_to :resource,
               polymorphic: true,
               optional: true

    belongs_to :participatory_space,
               optional: true,
               polymorphic: true

    belongs_to :version,
               optional: true,
               class_name: "PaperTrail::Version"

    belongs_to :area,
               foreign_key: "decidim_area_id",
               class_name: "Decidim::Area",
               optional: true

    scope :with_resource_type, lambda { |resource_type_key|
      if publicable_public_resource_types.include?(resource_type_key)
        where(resource_type: resource_type_key).where.not(action: "create")
      elsif public_resource_types.include?(resource_type_key)
        where(resource_type: resource_type_key)
      else
        with_all_resources
      end
    }

    scope :with_new_resource_type, lambda { |resource_type_key|
      if publicable_public_resource_types.include?(resource_type_key)
        where(resource_type: resource_type_key, action: "publish")
      elsif public_resource_types.include?(resource_type_key)
        where(resource_type: resource_type_key, action: "create")
      else
        with_all_new_resources
      end
    }

    scope :with_private_resources, lambda {
      where(
        "(action <> ? AND resource_type IN (?)) OR (resource_type IN (?))",
        "create",
        publicable_public_resource_types,
        (private_resource_types + public_resource_types - publicable_public_resource_types)
      )
    }

    scope :with_all_resources, lambda {
      where(
        "(action <> ? AND resource_type IN (?)) OR (resource_type IN (?))",
        "create",
        publicable_public_resource_types,
        (public_resource_types - publicable_public_resource_types)
      )
    }

    scope :with_all_new_resources, lambda {
      where(
        "(action = ? AND resource_type IN (?)) OR (action = ? AND resource_type IN (?))",
        "publish",
        publicable_public_resource_types,
        "create",
        (public_resource_types - publicable_public_resource_types)
      )
    }

    # Accepts a space filter that defines the participatory space manifest name
    # and ID. E.g. "participatory_processes(123)" where
    # "participatory_processes" is the manifest name and the number within the
    # parentheses is the ID.
    #
    # For this scope to work, the filter has to follow the given structure and
    # the participatory space name needs to match one of the registered
    # manifest names.
    scope :with_participatory_space, lambda { |space_filter|
      filter_match = space_filter.match(/([a-z_]+)\(([0-9]+)\)/)
      return self unless filter_match

      space_name = filter_match[1].to_sym
      space_id = filter_match[2]
      space_manifest = Decidim.participatory_space_manifests.find do |manifest|
        manifest.name == space_name
      end
      return self unless space_manifest

      where(
        participatory_space_type: space_manifest.model_class_name,
        participatory_space_id: space_id
      ).or(
        where(
          resource_type: space_manifest.model_class_name,
          resource_id: space_id
        )
      )
    }

    validates :action, presence: true
    validates :resource, presence: true, if: ->(log) { log.action != "delete" }
    validates :visibility, presence: true, inclusion: { in: %w(private-only admin-only public-only all) }

    # To ensure records can't be deleted
    before_destroy { |_record| raise ActiveRecord::ReadOnlyRecord }

    # A scope that filters all the logs that should be visible at the admin panel.
    def self.for_admin
      where(visibility: %w(admin-only all))
    end

    # All the resource types that are eligible to be included as an activity.
    def self.public_resource_types
      @public_resource_types ||= %w(
        Decidim::Accountability::Result
        Decidim::Blogs::Post
        Decidim::Comments::Comment
        Decidim::Consultations::Question
        Decidim::Debates::Debate
        Decidim::Meetings::Meeting
        Decidim::Proposals::Proposal
        Decidim::Surveys::Survey
        Decidim::Assembly
        Decidim::Consultation
        Decidim::Initiative
        Decidim::ParticipatoryProcess
      ).select do |klass|
        klass.safe_constantize.present?
      end
    end

    def self.private_resource_types
      @private_resource_types ||= %w(
        Decidim::Budgets::Order
      ).select do |klass|
        klass.safe_constantize.present?
      end
    end

    def self.publicable_public_resource_types
      @publicable_public_resource_types ||= public_resource_types.select { |klass| klass.constantize.column_names.include?("published_at") }
    end

    def self.ransackable_scopes(auth_object = nil)
      base = [:with_resource_type]
      return base unless auth_object&.admin?

      # Add extra scopes for admins for the admin panel searches
      base + [:with_participatory_space]
    end

    # Overwrites the method so that records cannot be modified.
    #
    # Returns a Boolean.
    def readonly?
      !new_record?
    end

    # Lazy loads the `component` association through BatchLoader, can be used
    # as a regular object.
    def component_lazy(cache: true)
      self.class.lazy_relation(decidim_component_id, "Decidim::Component", cache)
    end

    # Lazy loads the `organization` association through BatchLoader, can be used
    # as a regular object.
    def organization_lazy(cache: true)
      self.class.lazy_relation(decidim_organization_id, "Decidim::Organization", cache)
    end

    # Lazy loads the `user` association through BatchLoader, can be used
    # as a regular object.
    def user_lazy(cache: true)
      self.class.lazy_relation(decidim_user_id, "Decidim::User", cache)
    end

    # Lazy loads the `participatory_space` association through BatchLoader, can be used
    # as a regular object.
    def participatory_space_lazy(cache: true)
      return if participatory_space_id.blank? || participatory_space_type.blank?
      return resouce_lazy if participatory_space_id == resource_id && participatory_space_type == resource_type

      self.class.lazy_relation(participatory_space_id, participatory_space_type, cache)
    end

    # Lazy loads the `resource` association through BatchLoader, can be used
    # as a regular object.
    def resource_lazy(cache: true)
      self.class.lazy_relation(resource_id, resource_type, cache)
    end

    # Public: Finds the correct presenter class for the given
    # `log_type` and the related `resource_type`. If no specific
    # presenter can be found, it falls back to `Decidim::Log::BasePresenter`
    #
    # log_type - a Symbol representing the log
    #
    # Returns a Class.
    def log_presenter_class_for(log_type)
      resource_type.constantize.log_presenter_class_for(log_type)
    rescue NameError
      Decidim::Log::BasePresenter
    end

    # Returns a Batchloader for a given class to avoid N+1 queries.
    #
    # Since ActionLogs are related to many different resources, loading a collection
    # of them would trigger a lot of N+1 queries. We're using BatchLoader to
    # accumulate and group all the resource by their class and only loading them
    # when it's necessary.
    def self.lazy_relation(id_method, klass_name, cache)
      klass = klass_name.constantize
      BatchLoader.for(id_method).batch(cache:, key: klass.name.underscore) do |relation_ids, loader|
        scope = klass.where(id: relation_ids)

        scope = if klass.include?(Decidim::HasComponent)
                  scope.where(id: relation_ids).includes(:component).where.not(decidim_components: { published_at: nil })
                elsif klass.reflect_on_association(:organization)
                  scope.where(id: relation_ids).includes(:organization)
                elsif klass_name == "Decidim::Comments::Comment"
                  scope.where(id: relation_ids).includes([:moderation, :root_commentable, :user_group])
                else
                  scope
                end

        scope = scope.published if klass.include?(Decidim::Publicable)

        scope.each { |relation| loader.call(relation.id, relation) }
      end
    end

    # Whether this activity or log is visible for a given user (can also be nil)
    def visible_for?(user)
      resource_lazy.present? &&
        participatory_space_lazy.present? &&
        !resource_lazy.try(:deleted?) &&
        !resource_lazy.try(:hidden?) &&
        (!resource_lazy.respond_to?(:can_participate?) || resource_lazy.try(:can_participate?, user))
    rescue NameError => e
      Rails.logger.warn "Failed resource for #{self.class.name}(id=#{id}): #{e.message}"

      false
    end
  end
end
