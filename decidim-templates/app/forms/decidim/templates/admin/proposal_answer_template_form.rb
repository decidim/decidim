# frozen_string_literal: true

module Decidim
  module Templates
    module Admin
      class ProposalAnswerTemplateForm < TemplateForm
        attribute :internal_state, String
        attribute :scope_for_availability, String

        validates :internal_state, presence: true

        def map_model(model)
          self.scope_for_availability = "%s-%d" % [model.templatable_type.demodulize.tableize,model.templatable_id]
          (model.field_values || []).to_h.map do |k, v|
            self[k.to_sym] = v
          end
        end
      end
    end
  end
end
