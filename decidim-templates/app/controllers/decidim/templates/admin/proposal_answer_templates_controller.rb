# frozen_string_literal: true

module Decidim
  module Templates
    module Admin
      class ProposalAnswerTemplatesController < Decidim::Templates::Admin::ApplicationController
        include Decidim::TranslatableAttributes

        helper_method :avaliablity_options

        def new
          enforce_permission_to :create, :template
          @form = form(ProposalAnswerTemplateForm).instance
        end

        def edit
          enforce_permission_to :update, :template, template: template
          @form = form(ProposalAnswerTemplateForm).from_model(template)
          # @preview_form = form(Decidim::Forms::QuestionnaireForm).from_model(template.templatable)
        end

        def create
          enforce_permission_to :create, :template

          @form = form(ProposalAnswerTemplateForm).from_params(params)

          CreateProposalAnswerTemplate.call(@form) do
            on(:ok) do |template|
              flash[:notice] = I18n.t("templates.create.success", scope: "decidim.admin")
              redirect_to edit_proposal_answer_template_path(template)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("templates.create.error", scope: "decidim.admin")
              render :new
            end
          end
        end


        def update
          enforce_permission_to :update, :template, template: template
          @form = form(ProposalAnswerTemplateForm).from_params(params)
          UpdateProposalAnswerTemplate.call(template, @form, current_user) do
            on(:ok) do |questionnaire_template|
              flash[:notice] = I18n.t("templates.update.success", scope: "decidim.admin")
              redirect_to edit_proposal_answer_template_path(questionnaire_template)
            end

            on(:invalid) do |template|
              @template = template
              flash.now[:error] = I18n.t("templates.update.error", scope: "decidim.admin")
              render action: :edit
            end
          end
        end

        def index
          enforce_permission_to :index, :templates
          @templates = collection

          respond_to do |format|
            format.html { render :index }
            format.json do
              term = params[:term]

              @templates = search(term)

              render json: @templates.map { |t| { value: t.id, label: translated_attribute(t.name) } }
            end
          end
        end

        private

        def avaliablity_options
          options = [ ['Global scope', "organization-%d" % [current_organization.id] ]  ]
          options += Decidim::Component.includes(:participatory_space).where(manifest_name: :proposals)
                       .select{|a| a.participatory_space.decidim_organization_id == current_organization.id }.map do |component|
            [ formated_name(component), "components-%d" % component.id]
          end
          options
        end

        def formated_name(component)
          "%s ( %s )" % [translated_attribute(component.name), translated_attribute(component.participatory_space.title)]
        end

        def template
          @template ||= Template.find_by(id: params[:id])
        end

        def collection
          @collection ||= current_organization.templates.where(target: :proposal_answer)
        end
      end
    end
  end
end
