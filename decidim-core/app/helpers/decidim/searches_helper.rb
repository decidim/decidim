# frozen_string_literal: true

module Decidim
  # A Helper to render and link to resources.
  module SearchesHelper


    def radio_checked?(resource_type_radio_value)
      if @filters.nil?
        %q{checked="checked"} if resource_type_radio_value == "all"
      else
        %q{checked="checked"} if @filters[:resource_type].include?(resource_type_radio_value)
      end
    end

    def searchable_resources_class_names
      s_resources ||= []
      Decidim.feature_manifests.each do |feature_manifest|
        s_resources << feature_manifest.resource_manifests.last.model_class_name if feature_manifest.searchable_fields.present?
        # feature_manifest.resource_manifests.each do |resource_manifest|
        #   klass = resource_manifest.model_class_name.constantize
        #   klass_name = resource_manifest.model_class_name
        #   raise if klass_name.include? "Decidim::Meetings::Meeting"
        #
        #   raise if klass.included_modules.include? Decidim::Proposals::Proposal
          # klass.includes(:author).find_each do |resource|
          #
          # end
        # end
      end
      s_resources
    end

    def searchable_resource_human_name searchable_resource_class_name
      searchable_resource_class_name.constantize.model_name.human
    end

  end
end
