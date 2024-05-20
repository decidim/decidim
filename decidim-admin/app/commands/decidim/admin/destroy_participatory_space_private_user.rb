# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic to destroy a participatory space private user.
    class DestroyParticipatorySpacePrivateUser < Decidim::Commands::DestroyResource
      private

      def extra_params
        {
          resource: {
            title: resource.user.name
          }
        }
      end

      def run_after_hooks
        # A hook to destroy the follows of user on private non transparent assembly and its children
        # when private user is destroyed
        return unless resource.privatable_to_type == "Decidim::Assembly"

        assembly = Decidim::Assembly.find(resource.privatable_to_id)
        return unless assembly.private_space == true && assembly.is_transparent == false

        user = Decidim::User.find(resource.decidim_user_id)
        ids = []
        ids << Decidim::Follow.where(user:)
                              .where(decidim_followable_type: "Decidim::Assembly")
                              .where(decidim_followable_id: assembly.id)
                              .first.id
        children_ids = Decidim::Follow.where(user:)
                                      .select { |follow| find_object(follow).respond_to?("decidim_component_id") }
                                      .select { |follow| assembly.components.ids.include?(find_object(follow).decidim_component_id) }
                                      .map(&:id)
        ids << children_ids
        Decidim::Follow.where(user:).where(id: ids.flatten).destroy_all if ids.present?
      end

      def find_object(follow)
        follow.decidim_followable_type.constantize.find(follow.decidim_followable_id)
      end
    end
  end
end
