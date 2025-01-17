# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # Participatory Space Resourceable is a concern with the
  # features needed when you want to link a space
  # (for example `Participatory Process`) to another space (`Assembly`).
  #
  # The main difference between the two concerns `Resourceable` and
  # `ParticipatorySpaceResourceable` is that the first one is linking
  # component types between them, for example `Budgets` with `Proposals` and
  # therefore depend on a `Component`.
  #
  # The second one, `ParticipatorySpaceResourceable`, it is used for linking
  # `ParticipatorySpaces` to each other, and therefore do not depend on a
  # `Component` but rather that they depend to the `Organization`.

  module ParticipatorySpaceResourceable
    extend ActiveSupport::Concern

    included do
      extend Decidim::Deprecations

      # An association with all the links that point to this model.
      has_many :participatory_space_resource_links_to, as: :to, class_name: "Decidim::ParticipatorySpaceLink"

      # An association with all the links that are originated from this model.
      has_many :participatory_space_resource_links_from, as: :from, class_name: "Decidim::ParticipatorySpaceLink"

      delegate :resource_manifest, to: :class

      # Finds all the linked resources to or from this model for a given resource
      # name and link name.
      #
      # resource_name - The String name of the resource manifest exposed by a feature.
      # link_name     - The String name of the link between this model and the target resource.

      def linked_participatory_space_resources(resource_name, link_name)
        klass = "Decidim::#{resource_name.to_s.classify}"
        klass = klass.constantize
        from = klass
               .joins(:participatory_space_resource_links_from)
               .where(decidim_participatory_space_links: { name: link_name, to_id: id, to_type: self.class.name })

        to = klass
             .joins(:participatory_space_resource_links_to)
             .where(decidim_participatory_space_links: { name: link_name, from_id: id, from_type: self.class.name })

        query = klass.where(id: from).or(klass.where(id: to)).published

        if klass.column_names.include?("weight")
          query.order(:weight)
        else
          query.order(created_at: :desc)
        end
      end

      def participatory_space_sibling_scope(participatory_space_name)
        manifest = Decidim.find_participatory_space_manifest(participatory_space_name)
        return self.class.none unless manifest

        manifest.participatory_spaces.call(organization)
      end

      # Links the given resources to this model, replaces any previous links with the same name.
      #
      # resources - An Array or ActiveRecord::Base object to link to.
      # link_name - The String name to use as the name between the resources.
      # data      - An optional Hash to add to the link.
      #
      # Returns nothing.
      def link_participatory_space_resources(resources, link_name, data = {})
        transaction do
          participatory_space_resource_links_from.where(name: link_name).delete_all
          Array.wrap(resources).each do |resource|
            Decidim::ParticipatorySpaceLink.create!(
              from: self,
              to: resource,
              name: link_name,
              data:
            )
          end
        end
      end
      deprecated_alias :link_participatory_spaces_resources, :link_participatory_space_resources

      # Public: This method will be used to represent this participatory space in other contexts, like cards
      # or search results.
      def resource_title
        try(:title) || try(:name)
      end

      # Public: This method will be used to represent this participatory space in other contexts, like cards
      # or search results.
      def resource_description
        try(:description) || try(:body) || try(:content)
      end

      # Checks if this ParticipatorySpace should be visible in the public views.
      # i.e. checks
      # - is published
      # - is not private
      def visible?
        published? && !try(:private_space?)
      end

      # Defines a way to get the user roles for the current participatory space.
      # You should overwrite this method in the implementer class to define how
      # to get the correct values.
      #
      # role_name - A symbol or string identifying the role name
      #
      # Returns an ActiveRecord::Relation with one role for each combination of
      # `ParticipatorySpace` and `*UserRole`. `*` meaning that the concrete
      # implementation of the `UserRole` may change depending on the
      # `ParticipatorySpace` where it belongs to.
      def user_roles(_role_name = nil)
        self.class.none
      end

      def user_role_config_for(user, role_name)
        case role_name.to_sym
        when :organization_admin
          Decidim::ParticipatorySpaceRoleConfig::Admin.new(user)
        when :admin # ParticipatorySpace admin
          Decidim::ParticipatorySpaceRoleConfig::ParticipatorySpaceAdmin.new(user)
        when :evaluator
          Decidim::ParticipatorySpaceRoleConfig::Evaluator.new(user)
        when :moderator
          Decidim::ParticipatorySpaceRoleConfig::Moderator.new(user)
        when :collaborator
          Decidim::ParticipatorySpaceRoleConfig::Collaborator.new(user)
        else
          Decidim::ParticipatorySpaceRoleConfig::NullObject.new(user)
        end
      end
    end

    class_methods do
      # Finds the resource manifest for the model.
      #
      # Returns a Decidim::ResourceManifest
      def resource_manifest
        Decidim.find_resource_manifest(self)
      end
    end
  end
end
