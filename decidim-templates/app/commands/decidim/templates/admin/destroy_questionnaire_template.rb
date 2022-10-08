# frozen_string_literal: true

module Decidim
  module Templates
    module Admin
      class DestroyQuestionnaireTemplate < DestroyTemplate
        protected

        def destroy_template
          Decidim.traceability.perform_action!(
            :delete,
            template,
            current_user
          ) do
            template.destroy!
            template.templatable.destroy
          end
        end
      end
    end
  end
end
