# frozen_string_literal: true

module Decidim
  module Templates
    module Admin
      class ProposalAnswerTemplateForm < TemplateForm
        attribute :internal_state, String
        attribute :scope_for_availability, String

        validates :internal_state, presence: true

        def map_model(model)
          self.scope_for_availability = "#{model.templatable_type.try(:demodulize).try(:tableize)}-#{model.templatable_id.to_i}"
          (model.field_values || []).to_h.map do |k, v|
            self[k.to_sym] = v
          end
        end
      end
    end
  end
end
