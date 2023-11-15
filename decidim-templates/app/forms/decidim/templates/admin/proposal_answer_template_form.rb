# frozen_string_literal: true

module Decidim
  module Templates
    module Admin
      class ProposalAnswerTemplateForm < TemplateForm
        attribute :internal_state, String
        attribute :component_constraint, Integer

        validates :internal_state, presence: true

        def map_model(model)
          self.internal_state = model.field_values["internal_state"]
          self.component_constraint = if model.templatable_type == "Decidim::Organization"
                                        0
                                      else
                                        model.templatable&.id
                                      end
        end
      end
    end
  end
end
