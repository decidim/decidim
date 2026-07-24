# frozen_string_literal: true

module Decidim
  module Seeding
    # This module overrides some of the action logger functionality for the
    # seeding process in order to improve its performance. The recorded action
    # logs are stored in memory and committed to the database once the seeding
    # process completes. Also the consecutive fetches for the same related
    # records (organization, component, participatory space) are cached in
    # memory to avoid fetching them several times consecutively. This way, we
    # can avoid N+1 queries during the seeding process improving its
    # performance.
    module ActionLogger
      extend ActiveSupport::Concern

      included do
        def log!
          resource_id, resource_type =
            if resource.is_a?(Struct)
              [resource.id, resource.type]
            else
              [resource.id, resource.class.name]
            end

          self.class.queue_log(
            user_id: user.id,
            user_type: user.class.name,
            decidim_organization_id: organization&.id,
            action:,
            resource_id:,
            resource_type:,
            participatory_space_id: participatory_space&.id,
            participatory_space_type: participatory_space&.class&.name,
            decidim_component_id: component&.id,
            decidim_area_id: area&.id,
            decidim_scope_id: scope&.id,
            version_id:,
            extra: extra_data,
            visibility:
          )
        end

        private

        def organization
          Cache.organization(user.decidim_organization_id)
        end

        def component
          if resource.respond_to?(:budget)
            Cache.component(resource.budget&.decidim_component_id)
          elsif resource.respond_to?(:decidim_component_id)
            Cache.component(resource.decidim_component_id)
          end
        end

        def participatory_space
          if component.respond_to?(:participatory_space_id)
            Cache.participatory_space(component.participatory_space_type, component.participatory_space_id)
          elsif resource.respond_to?(:participatory_space)
            resource.participatory_space
          end
        end
      end

      class_methods do
        def queue_log(details)
          @queue ||= []
          @queue << details
        end

        def commit_logs
          return unless @queue

          Decidim::ActionLog.insert_all(@queue) # rubocop:disable Rails/SkipsModelValidations
        end
      end

      class Cache
        def self.organization(id)
          return unless id
          return @organization if @organization&.id == id

          @organization = Decidim::Organization.find(id)
        end

        def self.component(id)
          return unless id
          return @component if @component&.id == id

          @component = Decidim::Component.find(id)
        end

        def self.participatory_space(type, id)
          return unless type
          return unless id
          return @participatory_space if @participatory_space&.class&.name == type && @participatory_space&.id == id

          @participatory_space = type.constantize.find(id)
        end
      end
    end
  end
end
