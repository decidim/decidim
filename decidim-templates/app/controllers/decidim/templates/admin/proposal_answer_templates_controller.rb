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
        end

        def create
          enforce_permission_to :create, :template

          @form = form(ProposalAnswerTemplateForm).from_params(params)

          CreateProposalAnswerTemplate.call(@form) do
            on(:ok) do |_template|
              flash[:notice] = I18n.t("templates.create.success", scope: "decidim.admin")
              redirect_to proposal_answer_templates_path
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

          response_object = {
            state: template.field_values["internal_state"],
            template: populate_template_interpolations(proposal)
          }

          respond_to do |format|
            format.json do
              render json: response_object.to_json
            end
          end
        end

        def update
          enforce_permission_to :update, :template, template: template
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
          template.description.map do |row|
            language = row.first
            value = row.last
            value.gsub!("%{organization}", proposal.organization.name)
            value.gsub!("%{name}", proposal.creator_author.name)
            value.gsub!("%{admin}", current_user.name)

            [language, value]
          end.to_h
        end

        def proposal
          @proposal ||= Decidim::Proposals::Proposal.find(params[:proposalId])
        end

        def availability_option_as_text(template)
          return unless template.templatable_type

          key = "#{template.templatable_type.demodulize.tableize}-#{template.templatable_id}"
          avaliablity_options[key].presence || t("templates.missing_resource", scope: "decidim.admin")
        end

        def availability_options_for_select
          avaliablity_options.collect { |key, value| [value, key] }.to_a
        end

        def avaliablity_options
          @avaliablity_options = {}
          Decidim::Component.includes(:participatory_space).where(manifest_name: accepted_components)
                            .select { |a| a.participatory_space.decidim_organization_id == current_organization.id }.each do |component|
            @avaliablity_options["components-#{component.id}"] = formated_name(component)
          end
          global_scope = { "organizations-#{current_organization.id}" => t("global_scope", scope: "decidim.templates.admin.proposal_answer_templates.index") }
          @avaliablity_options = global_scope.merge(Hash[@avaliablity_options.sort_by { |_, val| val }])
        end

        def formated_name(component)
          space_type = t(component.participatory_space.class.name.underscore, scope: "activerecord.models", count: 1)
          "#{space_type}: #{translated_attribute(component.participatory_space.title)} > #{translated_attribute(component.name)}"
        end

        def accepted_components
          [:proposals]
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
