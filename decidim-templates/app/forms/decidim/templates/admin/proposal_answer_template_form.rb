# frozen_string_literal: true

module Decidim
  module Templates
    module Admin
      class ProposalAnswerTemplateForm < TemplateForm
        attribute :proposal_state_id, Integer
        attribute :component_constraint, Integer
        attribute :select_component, Boolean, default: false

        validate :component_has_been_selected
        validate :proposal_state_id_is_valid

        def map_model(model)
          self.proposal_state_id = model.field_values["proposal_state_id"]&.to_i
          self.component_constraint = model.templatable&.id
        end

        def skip_name_validation
          select_component
        end

        def proposal_state_id_is_valid
          if Decidim::Proposals::ProposalState.answerable.where(decidim_component_id: component_constraint).find_by(id: proposal_state_id).blank?
            errors.add(:proposal_state_id,
                       :blank)
          end
        end

        def component_has_been_selected
          errors.add(:select_component, :blank) if select_component
        end
      end
    end
  end
end
