# frozen_string_literal: true

module Decidim
  module Initiatives
    module Admin
      # Controller used to manage the initiatives answers
      class AnswersController < Decidim::Initiatives::Admin::ApplicationController
        include Decidim::Initiatives::NeedsInitiative

        helper Decidim::Initiatives::InitiativeHelper
        layout "decidim/admin/initiatives"

        # GET /admin/initiatives/:id/answer/edit
        def edit
          enforce_permission_to :answer, :initiative, initiative: current_initiative
          @form = form(Decidim::Initiatives::Admin::InitiativeAnswerForm)
                  .from_model(
                    current_initiative,
                    initiative: current_initiative
                  )
        end

        # PUT /admin/initiatives/:id/answer
        def update
          enforce_permission_to :answer, :initiative, initiative: current_initiative

          @form = form(Decidim::Initiatives::Admin::InitiativeAnswerForm)
                  .from_params(params, initiative: current_initiative)

          UpdateInitiativeAnswer.call(current_initiative, @form, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("initiatives.update.success", scope: "decidim.initiatives.admin")
              redirect_to initiatives_path
            end

            on(:invalid) do
              flash[:alert] = I18n.t("initiatives.update.error", scope: "decidim.initiatives.admin")
              redirect_to edit_initiative_answer_path
            end
          end
        end
      end
    end
  end
end
