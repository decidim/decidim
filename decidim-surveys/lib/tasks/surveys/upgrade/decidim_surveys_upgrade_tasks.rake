# frozen_string_literal: true

namespace :decidim_surveys do
  namespace :upgrade do
    # This is a Decidim 0.31.0 fix
    desc "Migrates the component permission from respond to response"
    task fix_survey_component_permissions: :environment do
      Decidim::Component.where(manifest_name: "surveys").find_each do |component|
        next if component.permissions.nil?

        if component.permissions.is_a?(Hash) && component.permissions.has_key?("answer")
          component.permissions["response"] = component.permissions["answer"]
          component.permissions.delete("answer")
          component.save!
        end

        if component.permissions.is_a?(Hash) && component.permissions.has_key?("respond")
          component.permissions["response"] = component.permissions["respond"]
          component.permissions.delete("respond")
          component.save!
        end
      end
    end
  end
end
