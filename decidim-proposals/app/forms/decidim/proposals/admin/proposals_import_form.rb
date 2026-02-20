# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # A form object to be used when admin users want to import a collection of proposals
      # from another component.
      class ProposalsImportForm < Decidim::Form
        include TranslatableAttributes
        mimic :proposals_import

        attribute :origin_component_id, Integer
        attribute :keep_answers, Boolean
        attribute :keep_authors, Boolean
        attribute :states, Array[String]

        validates :origin_component_id, :origin_component, :current_component, presence: true
        validates :states, presence: true

        def states
          super.compact_blank
        end

        def origin_component
          @origin_component ||= origin_components.find_by(id: origin_component_id)
        end

        def origin_components
          @origin_components ||= current_participatory_space.components.where.not(id: current_component.id).where(manifest_name: :proposals)
        end

        def origin_components_collection
          origin_components.map do |component|
            [component.name[I18n.locale.to_s], component.id]
          end
        end
      end
    end
  end
end
