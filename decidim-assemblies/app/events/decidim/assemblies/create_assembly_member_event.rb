# frozen_string_literal: true

module Decidim
  module Assemblies
    class CreateAssemblyMemberEvent < Decidim::Events::SimpleEvent
      i18n_attributes :resource_name

      def resource_name
        @resource_name ||= decidim_sanitize_translated(assembly.title)
      end

      def assembly
        @assembly ||= resource
      end
    end
  end
end
