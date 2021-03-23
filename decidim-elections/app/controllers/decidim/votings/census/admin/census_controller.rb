# frozen_string_literal: true

module Decidim
  module Votings
    module Census
      module Admin
        # This controller allows to create or update the census.
        class CensusController < Admin::ApplicationController
          helper_method :votings, :current_participatory_space, :current_census, :census_steps, :current_census_action_view,
                        :admin_voting_census_path, :admin_status_voting_census_path, :generate_access_codes_path

          def show
            enforce_permission_to :manage, :census, voting: current_participatory_space

            flash[:notice] = "Finished processing #{current_census.file}" if current_census.data_created?

            @form = form(DatasetForm).instance
          end

          def create
            enforce_permission_to :manage, :census, voting: current_participatory_space

            @form = form(DatasetForm).from_params(params).with_context(
              current_participatory_space: current_participatory_space
            )

            CreateDataset.call(@form, current_user) do
              on(:invalid) do
                flash[:alert] = t("create.error", scope: "decidim.votings.census.admin.census")
              end
            end

            redirect_to admin_voting_census_path
          end

          def destroy
            enforce_permission_to :manage, :census, voting: current_participatory_space

            DestroyDataset.call(current_census, current_user) do
              on(:ok) do
                flash[:notice] = t("destroy.success", scope: "decidim.votings.census.admin.census")
              end

              on(:invalid) do
                flash[:alert] = t("destroy.error", scope: "decidim.votings.census.admin.census")
              end
            end

            redirect_to admin_voting_census_path
          end

          def status
            respond_to do |format|
              format.js
            end
          end

          def generate_access_codes
            enforce_permission_to :manage, :census, voting: current_participatory_space

            LaunchAccessCodesGeneration.call(current_census, current_user) do
              on(:ok) do
                flash[:notice] = t("generate_access_codes.launch_success", scope: "decidim.votings.census.admin.census")
              end

              on(:invalid) do
                flash[:alert] = t("generate_access_codes.launch_error", scope: "decidim.votings.census.admin.census")
              end
            end

            redirect_to admin_voting_census_path
          end

          private

          def votings
            @votings ||= OrganizationVotings.new(current_user.organization).query
          end

          def current_participatory_space
            @current_participatory_space ||= votings.where(slug: params[:voting_slug]).or(
              votings.where(id: params[:voting_slug])
            ).first
          end

          def current_census
            @current_census ||= Dataset.find_by(
              voting: current_participatory_space
            ) || Dataset.new(status: :init_data)
          end

          def admin_voting_census_path
            decidim_votings_admin.voting_census_path(current_participatory_space)
          end

          def admin_status_voting_census_path
            decidim_votings_admin.status_voting_census_path(current_participatory_space)
          end

          def generate_access_codes_path
            decidim_votings_admin.generate_access_codes_voting_census_path(current_participatory_space)
          end

          def current_census_action_view
            case current_census.status
            when "init_data"
              "new_census"
            when "creating_data"
              "creating_data"
            when "data_created"
              "generate_codes"
            when "generating_codes"
              "generating_codes"
            when "codes_generated"
              "export_codes"
            when "freeze"
              "freeze"
            else
              raise "no view for this status"
            end
          end
        end
      end
    end
  end
end
