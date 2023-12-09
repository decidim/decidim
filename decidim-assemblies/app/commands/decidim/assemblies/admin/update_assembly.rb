# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # A command with all the business logic when creating a new participatory
      # assembly in the system.
      class UpdateAssembly < Decidim::Commands::UpdateResource
        include ::Decidim::AttachmentAttributesMethods

        fetch_form_attributes :title, :subtitle, :slug, :hashtag, :promoted, :description, :short_description,
                              :scopes_enabled, :scope, :area, :parent, :private_space, :developer_group, :local_area,
                              :target, :participatory_scope, :participatory_structure, :meta_scope, :show_statistics,
                              :purpose_of_action, :composition, :assembly_type, :creation_date, :created_by,
                              :created_by_other, :duration, :included_at, :closing_date, :closing_date_reason,
                              :internal_organisation, :is_transparent, :special_features, :twitter_handler, :announcement,
                              :facebook_handler, :instagram_handler, :youtube_handler, :github_handler, :weight

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form was not valid and we could not proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          update_resource
          link_participatory_processes(resource)
          update_children_count

          broadcast(:ok, resource)
        rescue ActiveRecord::RecordInvalid
          form.errors.add(:hero_image, resource.errors[:hero_image]) if resource.errors.include? :hero_image
          form.errors.add(:banner_image, resource.errors[:banner_image]) if resource.errors.include? :banner_image
          broadcast(:invalid)
        end

        private

        def parent
          @parent ||= Assembly.find_by(id: resource.parent)
        end

        def attributes
          super.merge(attachment_attributes(:hero_image, :banner_image))
        end

        def participatory_processes(assembly)
          @participatory_processes ||= assembly.participatory_space_sibling_scope(:participatory_processes).where(id: form.participatory_processes_ids)
        end

        def link_participatory_processes(assembly)
          assembly.link_participatory_space_resources(participatory_processes(assembly), "included_participatory_processes")
        end

        # Resets the children counter cache to its correct value using an SQL count query.
        # Fixes Rails decrementing twice error when updating the parent to nil.
        #
        # Returns nothing.
        def update_children_count
          return unless parent

          Assembly.reset_counters(parent.id, :children_count)
        end
      end
    end
  end
end
