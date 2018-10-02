# frozen_string_literal: true

module Decidim
  # This class represents an action of a user on a resource. It is used
  # for transparency reasons, to log all actions so all other users can
  # see the actions being performed.
  class ActionLog < ApplicationRecord
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

    validates :organization, :user, :action, presence: true
    validates :resource, presence: true, if: ->(log) { log.action != "delete" }
    validates :visibility, presence: true, inclusion: { in: %w(admin-only public-only all) }

    # To ensure records can't be deleted
    before_destroy { |_record| raise ActiveRecord::ReadOnlyRecord }

    # A scope that filters all the logs that should be visible at the admin panel.
    def self.for_admin
      where(visibility: %w(admin-only all))
    end

    # Overwrites the method so that records cannot be modified.
    #
    # Returns a Boolean.
    def readonly?
      !new_record?
    end

    def component_lazy(cache: true)
      self.class.lazy_relation(decidim_component_id, "Decidim::Component", cache)
    end

    def organization_lazy(cache: true)
      self.class.lazy_relation(decidim_organization_id, "Decidim::Organization", cache)
    end

    def user_lazy(cache: true)
      self.class.lazy_relation(decidim_user_id, "Decidim::User", cache)
    end

    def participatory_space_lazy(cache: true)
      return if participatory_space_id.blank? || participatory_space_type.blank?
      return resouce_lazy if participatory_space_id == resource_id && participatory_space_type == resource_type

      self.class.lazy_relation(participatory_space_id, participatory_space_type, cache)
    end

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

    def self.lazy_relation(id_method, klass_name, cache)
      klass = klass_name.constantize
      BatchLoader.for(id_method).batch(cache: cache, key: klass.name.underscore) do |relation_ids, loader|
        scope = klass.where(id: relation_ids)

        scope = if klass.include?(Decidim::HasComponent)
                  scope.where(id: relation_ids).includes(:component).where.not(decidim_components: { published_at: nil })
                elsif klass.reflect_on_association(:organization)
                  scope.where(id: relation_ids).includes(:organization)
                elsif klass_name == "Decidim::Comments::Comment"
                  scope.where(id: relation_ids).includes(commentable: :organization)
                else
                  scope
                end

        scope = scope.published if klass.include?(Decidim::Publicable)

        scope.each { |relation| loader.call(relation.id, relation) }
      end
    end
  end
end
