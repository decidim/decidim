# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      class ElectionsController < Admin::ApplicationController
        helper Decidim::Elections::Admin::ElectionsHelper
        include Decidim::Admin::HasTrashableResources
        include Decidim::ApplicationHelper
        include Decidim::Elections::Admin::Filterable

        helper_method :elections, :election, :election_questions

        def index
          enforce_permission_to :read, :election
        end

        def new
          enforce_permission_to :create, :election
          @form = form(Decidim::Elections::Admin::ElectionForm).from_params(
            attachment: form(AttachmentForm).from_params({})
          )
        end

        def create
          enforce_permission_to :create, :election

          @form = form(Decidim::Elections::Admin::ElectionForm).from_params(params, current_component:)

          CreateElection.call(@form) do
            on(:ok) do |election|
              flash[:notice] = I18n.t("elections.create.success", scope: "decidim.elections.admin")
              redirect_to edit_questions_election_path(election)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("elections.create.invalid", scope: "decidim.elections.admin")
              render action: "new"
            end
          end
        end

        def edit
          enforce_permission_to :update, :election, election: election
          @form = form(Decidim::Elections::Admin::ElectionForm).from_model(election)
        end

        def update
          enforce_permission_to :update, :election, election: election

          @form = form(Decidim::Elections::Admin::ElectionForm).from_params(params, current_component:, election:)

          UpdateElection.call(@form, election) do
            on(:ok) do
              flash[:notice] = I18n.t("elections.update.success", scope: "decidim.elections.admin")
              redirect_to election.published? ? dashboard_page_election_path(election) : edit_questions_election_path(election)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("elections.update.invalid", scope: "decidim.elections.admin")
              render action: "edit"
            end
          end
        end

        def publish
          enforce_permission_to :publish, :election, election: election

          PublishElection.call(election, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("elections.publish.success", scope: "decidim.elections.admin")
              redirect_to dashboard_page_election_path(election)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("elections.publish.invalid", scope: "decidim.elections.admin")
              render action: "index"
            end
          end
        end

        def unpublish
          enforce_permission_to :unpublish, :election, election: election

          Decidim::Elections::Admin::UnpublishElection.call(election, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("elections.unpublish.success", scope: "decidim.elections.admin")
              redirect_to elections_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("elections.unpublish.invalid", scope: "decidim.elections.admin")
              render action: "index"
            end
          end
        end

        def dashboard_page
          enforce_permission_to :dashboard, :election, election: election
        end

        def update_status
          enforce_permission_to :update, :election, election: election

          @form = form(ElectionStatusForm).from_params(params)

          UpdateElectionStatus.call(@form, election) do
            on(:ok) do
              flash[:notice] = I18n.t("statuses.#{@form.status_action}.success", scope: "decidim.elections.admin")
              redirect_to dashboard_page_election_path(election)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("statuses.unknown", scope: "decidim.elections.admin")
              render action: "dashboard_page"
            end
          end
        end

        private

        def elections
          @elections ||= filtered_collection
        end

        def collection
          @collection ||= Election.where(component: current_component).not_hidden
        end

        def trashable_deleted_resource_type
          :election
        end

        def trashable_deleted_collection
          @trashable_deleted_collection ||= elections.only_deleted.deleted_at_desc
        end

        def trashable_deleted_resource
          @trashable_deleted_resource ||= Election.with_deleted.find_by(component: current_component, id: params[:id])
        end

        def election
          @election ||= elections.find(params[:id])
        end

        def election_questions
          @election_questions ||= election.questions.includes(:response_options)
        end
      end
    end
  end
end
