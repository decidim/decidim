# frozen_string_literal: true

module Decidim
  module Templates
    module Admin
      class ProposalAnswerTemplatesController < Decidim::Templates::Admin::ApplicationController
        include Decidim::TranslatableAttributes
        include Decidim::Paginable

        helper_method :availability_option_as_text, :availability_options_for_select

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

        def destroy
          enforce_permission_to :destroy, :template, template: template

          DestroyTemplate.call(template, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("templates.destroy.success", scope: "decidim.admin")
              redirect_to action: :index
            end
          end
        end

        def fetch
          enforce_permission_to :read, :template, template: template
          # enforce_permission_to :create, :proposal_answer, proposal: proposal

          response_object = {
            state: template.field_values["internal_state"],
            template: populate_template_interpolations(proposal)
          }

          respond_to do |format|
            format.json {
              render json: response_object.to_json
            }
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

        def copy
          enforce_permission_to :copy, :template

          CopyProposalAnswerTemplate.call(template) do
            on(:ok) do
              flash[:notice] = I18n.t("templates.copy.success", scope: "decidim.admin")
              redirect_to action: :index
            end

            on(:invalid) do
              flash[:alert] = I18n.t("templates.copy.error", scope: "decidim.admin")
              redirect_to action: :index
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

        def populate_template_interpolations(proposal)
          template.description.each do |row|
            row.last.gsub!('%{organization}', proposal.organization.name)
            row.last.gsub!('%{name}', proposal.creator_author.name)
            row.last.gsub!('%{admin}', current_user.name)
            [row.first, row.last]
          end.to_h
        end

        def proposal
          @proposal ||= Decidim::Proposals::Proposal.find(params[:proposal_id])
        end

        def availability_option_as_text(template)
          key = "%s-%d" % [template.templatable_type.demodulize.tableize,template.templatable_id]
          avaliablity_options.fetch(key)
        end

        def availability_options_for_select
          avaliablity_options.collect {|key, value| [value, key] }.to_a
        end

        def avaliablity_options
          @avaliablity_options = { "organizations-%d" % [current_organization.id] => t('global_scope', scope: 'decidim.templates.admin.proposal_answer_templates.index')}
          Decidim::Component.includes(:participatory_space).where(manifest_name: :proposals)
            .select{|a| a.participatory_space.decidim_organization_id == current_organization.id }.each do |component|
            @avaliablity_options["components-%d" % component.id] = formated_name(component)
          end
          @avaliablity_options
        end

        def formated_name(component)
          "%s ( %s )" % [translated_attribute(component.name), translated_attribute(component.participatory_space.title)]
        end

        def template
          @template ||= Template.find_by(id: params[:id])
        end

        def collection
          @collection ||= paginate(current_organization.templates.where(target: :proposal_answer).order(:id))
        end
      end
    end
  end
end
