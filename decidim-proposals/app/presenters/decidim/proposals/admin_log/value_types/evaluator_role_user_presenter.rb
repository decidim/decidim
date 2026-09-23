# frozen_string_literal: true

module Decidim
  module Proposals
    module AdminLog
      module ValueTypes
        class EvaluatorRoleUserPresenter < Decidim::Log::ValueTypes::DefaultPresenter
          def present
            return unless value

            assignment = Decidim::Proposals::EvaluationAssignment.find_by(evaluator_role_id: value)
            return unless assignment

            assignment.evaluator_role&.user&.name
          end
        end
      end
    end
  end
end
