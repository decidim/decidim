# frozen_string_literal: true

module Decidim
  #  A command with all the business logic when an admin batch updates resources scope.
  class UpdateResourcesTaxonomies < Decidim::Command
    # Public: Initializes the command.
    #
    # taxonomy_ids - the taxonomy ids to update
    # resources - an ApplicationRecord collection of resources to update.
    def initialize(taxonomy_ids, resources, organization)
      @organization = organization
      @taxonomies = Decidim::Taxonomy.non_roots.where(organization:, id: taxonomy_ids)
      @resources = resources
      @response = { taxonomies: [], successful: [], errored: [] }
    end

    # Executes the command. Broadcasts these events:
    #
    # - :update_resources_taxonomies - when everything is ok, returns @response.
    # - :invalid_taxonomies - if the taxonomy is blank.
    # - :invalid_resources - if the resource_ids is blank.
    #
    # Returns @response hash:
    #
    # - :taxonomies - Array of the updated taxonomies
    # - :successful - Array of names of the updated resources
    # - :errored - Array of names of the resources not updated because they already had the scope assigned
    def call
      return broadcast(:invalid_taxonomies) if @taxonomies.blank?
      return broadcast(:invalid_resources) if @resources.blank? || !@resources.respond_to?(:find_each)

      update_resources_taxonomies

      broadcast(:update_resources_taxonomies, @response)
    end

    # Useful for running any code that you may want to execute before creating the resource.
    def run_before_hooks(resource); end

    # Useful for running any code that you may want to execute after creating the resource.
    def run_after_hooks(resource); end

    private

    attr_reader :taxonomies, :resources, :organization

    def update_resources_taxonomies
      @response[:taxonomies] = taxonomies
      resources.find_each do |resource|
        if taxonomies == resource.taxonomies
          @response[:errored] << resource
        else
          update_resource_taxonomies!(resource)
          @response[:successful] << resource
        end
      end
    end

    def update_resource_taxonomies!(resource)
      transaction do
        run_before_hooks(resource)
        resource.update!(taxonomies:)
        run_after_hooks(resource)
      end
    end
  end
end
