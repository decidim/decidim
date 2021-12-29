# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # Controller that allows managing assembly members.
      #
      class AssemblyMembersController < Decidim::Assemblies::Admin::ApplicationController
        include Concerns::AssemblyAdmin
        layout "decidim/admin/assembly_members"

        def index
          enforce_permission_to :index, :assembly_member

          @query = params[:q]
          @status = params[:status]

          @assembly_members = Decidim::Assemblies::Admin::AssemblyMembers.for(collection, @query, @status).page(params[:page]).per(15)
        end

        def new
          enforce_permission_to :create, :assembly_member
          @form = form(AssemblyMemberForm).instance
        end

        def create
          enforce_permission_to :create, :assembly_member
          @form = form(AssemblyMemberForm).from_params(params)

          CreateAssemblyMember.call(@form, current_user, current_assembly) do
            on(:ok) do
              flash[:notice] = I18n.t("assembly_members.create.success", scope: "decidim.admin")
              redirect_to assembly_members_path(current_assembly)
            end

            on(:invalid) do
              flash[:alert] = I18n.t("assembly_members.create.error", scope: "decidim.admin")
              render :new
            end
          end
        end

        def edit
          @assembly_member = collection.find(params[:id])
          enforce_permission_to :update, :assembly_member, member: @assembly_member
          @form = form(AssemblyMemberForm).from_model(@assembly_member)
        end

        def update
          @assembly_member = collection.find(params[:id])
          enforce_permission_to :update, :assembly_member, member: @assembly_member
          @form = form(AssemblyMemberForm).from_params(params)

          UpdateAssemblyMember.call(@form, @assembly_member) do
            on(:ok) do
              flash[:notice] = I18n.t("assembly_members.update.success", scope: "decidim.admin")
              redirect_to assembly_members_path(current_assembly)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("assembly_members.update.error", scope: "decidim.admin")
              render :edit
            end
          end
        end

        def destroy
          @assembly_member = collection.find(params[:id])
          enforce_permission_to :destroy, :assembly_member, member: @assembly_member

          DestroyAssemblyMember.call(@assembly_member, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("assembly_members.destroy.success", scope: "decidim.admin")
              redirect_to assembly_members_path(current_assembly)
            end
          end
        end

        private

        def collection
          @collection ||= Decidim::AssemblyMember.where(assembly: current_assembly)
        end
      end
    end
  end
end
