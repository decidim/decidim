# frozen_string_literal: true

module Decidim
  module Votings
    module Census
      module Admin
        # This controller allows to create or update the census.
        class CensusController < Admin::ApplicationController
          helper_method :votings, :current_participatory_space, :current_census, :census_steps, :current_census_action_view, :admin_voting_census_path

          def show
            enforce_permission_to :manage, :census, voting: current_participatory_space

            @form = form(DatasetForm).instance
          end

          def create
            enforce_permission_to :manage, :census, voting: current_participatory_space

            @form = form(DatasetForm).from_params(params).with_context(
              current_participatory_space: current_participatory_space
            )

            CreateDataset.call(@form, current_user) do
              on(:ok) do
                flash[:notice] = t("create.success", scope: "decidim.votings.census.admin.census")
              end

              on(:invalid) do
                flash[:alert] = t("create.error", scope: "decidim.votings.census.admin.census")
              end
            end

            redirect_to admin_voting_census_path
          end

          def update
            enforce_permission_to :manage, :census, voting: current_participatory_space

            @form = form(DatasetForm).from_params(params).with_context(
              current_participatory_space: current_participatory_space,
              voting: current_participatory_space,
              census: current_census
            )

            UpdateDataset.call(@form, current_user) do
              on(:ok) do
                flash[:notice] = t("update.success", scope: "decidim.votings.census.admin.census")
              end

              on(:invalid) do
                flash[:alert] = t("update.error", scope: "decidim.votings.census.admin.census")
              end
            end

            redirect_to admin_voting_census_path
          end

          def destroy
            enforce_permission_to :manage, :census, voting: current_participatory_space

            if current_census.destroy
              flash[:notice] = t("destroy.success", scope: "decidim.votings.census.admin.census")
            else
              flash[:alert] = t("destroy.error", scope: "decidim.votings.census.admin.census")
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
              organization: current_organization,
              voting: current_participatory_space
            ) || Dataset.new(status: :create_data)
          end

          def census_steps
            [
              ["Create census", current_step(:create_data)],
              ["Review Data", current_step(:review_data)],
              ["Create Acess Codes", current_step(:generate_codes)],
              ["Export Acess Codes", current_step(:export_codes)],
              ["Unlock Election", current_step(:freeze)]
            ]
          end

          def current_step(step)
            if step == current_census.status.to_sym
              :current
            else
              current_pointer = Dataset.statuses[current_census.status]
              pointer = Dataset.statuses[step]

              pointer > current_pointer ? :next : :prev
            end
          end

          def admin_voting_census_path
            decidim_votings_admin.voting_census_path(current_participatory_space)
          end

          def current_census_action_view
            case current_census.status
            when "create_data"
              "new_census"
            when "review_data"
              "update_census"
            else
              raise "no view for this status"
            end
          end
        end
      end
    end
  end
end
