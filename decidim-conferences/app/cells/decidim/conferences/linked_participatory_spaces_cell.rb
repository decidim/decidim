# frozen_string_literal: true

module Decidim
  module Conferences
    # This cell renders a collection of linked Participatory Space of current conference.
    # `model` is the current conference
    class LinkedParticipatorySpacesCell < Decidim::ViewModel
      include Decidim::ApplicationHelper
      include Decidim::CardHelper

      def show
        render
      end

      private

      def conference_spaces
        [conference_participatory_processes, conference_assemblies, conference_consultations].compact
      end

      def conference_participatory_processes
        return unless Decidim.participatory_space_manifests.map(&:name).include?(:participatory_processes)

        processes = model.linked_participatory_space_resources(:participatory_processes, "included_participatory_processes")
        return unless processes.any?

        processes
      end

      def conference_assemblies
        return unless Decidim.participatory_space_manifests.map(&:name).include?(:assemblies)

        assemblies = model.linked_participatory_space_resources(:assemblies, "included_assemblies")
        return unless assemblies.any?

        assemblies
      end

      def conference_consultations
        return unless Decidim.participatory_space_manifests.map(&:name).include?(:consultations)

        consultations = model.linked_participatory_space_resources(:consultations, "included_consultations")
        return unless consultations.any?

        consultations
      end

      def title(block_space)
        block_space.first.class.name.demodulize.tableize
      end
    end
  end
end
