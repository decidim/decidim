# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # A form object to be used when admin users want to import a collection of proposals
      # from another component into answers resource.
      class AnswerImportProposalsForm < Decidim::Form
        mimic :proposals_import

        attribute :origin_component_id, Integer
        attribute :import_all_accepted_proposals, Boolean
        attribute :weight, Integer, default: 0

        validates :origin_component_id, :origin_component, :current_component, presence: true

        def origin_component
          @origin_component ||= origin_components.find_by(id: origin_component_id)
        end

        def origin_components
          @origin_components ||= current_participatory_space.components.where(manifest_name: :proposals)
        end

        def origin_components_collection
          origin_components.map do |component|
            [component.name[I18n.locale.to_s], component.id]
          end
        end

        def election
          @election ||= context[:election]
        end

        def question
          @question ||= context[:question]
        end
      end
    end
  end
end
