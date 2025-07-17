# frozen_string_literal: true

namespace :decidim_surveys do
  namespace :upgrade do
    desc "Migrates the component permission from answer to respond"
    task fix_survey_permissions: :environment do
      Decidim::Component.where(manifest_name: "surveys").find_each do |component|
        next if component.permissions.nil?

        if component.permissions.is_a?(Hash) && component.permissions.has_key?("answer")
          component.permissions["respond"] = component.permissions["answer"]
          component.permissions.delete("answer")
          component.save!
        end
      end

      Decidim::ResourcePermission.where(resource_type: "Decidim::Surveys::Survey").find_each do |resource|
        next if resource.permissions.nil?

        if resource.permissions.is_a?(Hash) && resource.permissions.has_key?("answer")
          resource.permissions["respond"] = resource.permissions["answer"]
          resource.permissions.delete("answer")
          resource.save!
        end
      end
    end
  end
end
