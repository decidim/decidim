# frozen_string_literal: true

module Decidim
  module Templates
    module Admin
      class ProposalAnswerTemplatesController < Decidim::Templates::Admin::ApplicationController
        include Decidim::TranslatableAttributes
        include Decidim::Paginable

        helper_method :availability_option_as_text, :availability_options_for_select, :available_states, :proposal_state

        def new
          enforce_permission_to :create, :template
          @form = form(ProposalAnswerTemplateForm).instance
        end

        def edit
          enforce_permission_to(:update, :template, template:)
          @form = form(ProposalAnswerTemplateForm).from_model(template)
        end

        def create
          enforce_permission_to :create, :template

          @form = form(ProposalAnswerTemplateForm).from_params(params)

          CreateProposalAnswerTemplate.call(@form) do
            on(:ok) do |_template|
              flash[:notice] = I18n.t("templates.create.success", scope: "decidim.admin")
              redirect_to proposal_answer_templates_path
            end

            on(:component_selected) do
              render :new
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("templates.create.error", scope: "decidim.admin")
              render :new
            end
          end
        end

        def destroy
          enforce_permission_to(:destroy, :template, template:)

          DestroyTemplate.call(template, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("templates.destroy.success", scope: "decidim.admin")
              redirect_to action: :index
            end
          end
        end

        def fetch
          enforce_permission_to(:read, :template, template:)

          state = fetch_proposal_state(template)

          response_object = {
            state: state&.token,
            template: populate_template_interpolations(proposal)
          }

          respond_to do |format|
            format.json do
              render json: response_object.to_json
            end
          end
        end

        def update
          enforce_permission_to(:update, :template, template:)
          @form = form(ProposalAnswerTemplateForm).from_params(params)
          UpdateProposalAnswerTemplate.call(template, @form, current_user) do
            on(:ok) do |_questionnaire_template|
              flash[:notice] = I18n.t("templates.update.success", scope: "decidim.admin")
              redirect_to proposal_answer_templates_path
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

          CopyProposalAnswerTemplate.call(template, current_user) do
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

        def fetch_proposal_state(template)
          available_states(template.templatable_id).find_by(id: template.field_values["proposal_state_id"])
        end

        def proposal_state(template)
          state = fetch_proposal_state(template)

          state ? translated_attribute(state&.title) : I18n.t("decidim.templates.admin.proposal_answer_templates.index.missing_state")
        end

        def available_states(component_id = nil)
          Decidim::Proposals::ProposalState.answerable.where(decidim_component_id: component_id)
        end

        def populate_template_interpolations(proposal)
          template.description.to_h do |language, value|
            value.gsub!("%{organization}", proposal.organization.name)
            value.gsub!("%{name}", author_name(proposal))
            value.gsub!("%{admin}", current_user.name)

            [language, value]
          end
        end

        def author_name(proposal)
          proposal.creator_author.try(:title) || proposal.creator_author.try(:name)
        end

        def proposal
          @proposal ||= Decidim::Proposals::Proposal.find(params[:proposalId])
        end

        def availability_option_as_text(template)
          return unless template.templatable_type
          return t("global_scope", scope: "decidim.templates.admin.proposal_answer_templates.index") if template.templatable == current_organization

          avaliablity_options.select { |a| a.last == template.templatable_id }&.flatten&.first || t("templates.missing_resource", scope: "decidim.admin")
        end

        def availability_options_for_select
          avaliablity_options
        end

        def avaliablity_options
          @avaliablity_options = []
          Decidim::Component.includes(:participatory_space).where(manifest_name: [:proposals])
                            .select { |a| a.participatory_space.decidim_organization_id == current_organization.id }.each do |component|
            @avaliablity_options.push [formatted_name(component), component.id]
          end

          @avaliablity_options
        end

        def formatted_name(component)
          space_type = t(component.participatory_space.class.name.underscore, scope: "activerecord.models", count: 1)
          "#{space_type}: #{translated_attribute(component.participatory_space.title)} > #{translated_attribute(component.name)}"
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
