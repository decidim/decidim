# frozen_string_literal: true

namespace :decidim do
  namespace :upgrade do
    desc "Delete follows of ex private users"
    task fix_deleted_private_follows: :environment do
      def find_object(follow)
        follow.decidim_followable_type.constantize.find(follow.decidim_followable_id)
      end

      def delete_unwanted_follows(model, elements, children_follows)
        count = 0
        p "begin deleting follows"
        elements.each do |element|
          # for each element, find their private users
          private_users_ids = Decidim::ParticipatorySpacePrivateUser.where(privatable_to_id: element.id, privatable_to_type: model.to_s).pluck(:decidim_user_id)
          # delete follows from non private users
          direct_follows_to_delete = Decidim::Follow.where(followable: element.id, decidim_followable_type: model.to_s)
                                                    .where.not(decidim_user_id: private_users_ids)
          count += direct_follows_to_delete.size
          direct_follows_to_delete.destroy_all
          # children of element
          element_components_ids = element.components.ids
          children_follows_to_delete = children_follows.select { |follow| element_components_ids.include?(find_object(follow).decidim_component_id) }
                                                       .reject { |follow| private_users_ids.include?(follow.decidim_user_id) }
          count += children_follows_to_delete.size
          children_follows_to_delete.map { |follow| Decidim::Follow.delete(follow.id) }
        end
        p "#{count} follows have been deleted for #{model} and their children"
      end
      children_follows = Decidim::Follow.select { |follow| find_object(follow).respond_to?(:decidim_component_id) }
      # find private non transparent assemblies
      assemblies = Decidim::Assembly.where(private_space: true, is_transparent: false)
      # delete unwanted follows
      delete_unwanted_follows(Decidim::Assembly, assemblies, children_follows)
      # find private processes
      processes = Decidim::ParticipatoryProcess.where(private_space: true)
      # delete unwanted follows
      delete_unwanted_follows(Decidim::ParticipatoryProcess, processes, children_follows)
    end
  end
end
