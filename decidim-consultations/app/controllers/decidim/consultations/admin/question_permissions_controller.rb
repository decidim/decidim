# frozen_string_literal: true

module Decidim
  module Consultations
    module Admin
      # Controller that allows managing Questions
      # permissions in the admin panel.
      class QuestionPermissionsController < Decidim::Admin::ResourcePermissionsController
        include QuestionAdmin
        # layout "decidim/admin/Question"

        register_permissions(::Decidim::Consultations::Admin::QuestionPermissionsController,
                             ::Decidim::Consultations::Permissions,
                             ::Decidim::Admin::Permissions)

        def permission_class_chain
          ::Decidim.permissions_registry.chain_for(::Decidim::Consultations::Admin::QuestionPermissionsController)
        end

        def edit
          enforce_permission_to :update, :question, question: current_question
          super
        end

        def update
          enforce_permission_to :update, :question, question: current_question
          super
        end

        def return_path
          consultation_questions_path current_consultation
        end
      end
    end
  end
end
