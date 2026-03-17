# frozen_string_literal: true

module Decidim
  module Admin
    module ParticipatorySpace
      module Concerns
        # Members can be related to any ParticipatorySpace, in order to
        # manage the members for a given type, you should create a new
        # controller and include this concern.
        #
        # It takes the current_participatory_space that is defined
        # in the controller, so there is no need to define any method
        module HasMembers
          extend ActiveSupport::Concern

          included do
            include Decidim::Admin::ParticipatorySpace::Concerns::MembersFilterable

            helper PaginateHelper
            helper_method :members

            # rubocop:disable Rails/LexicallyScopedActionFilter
            before_action :set_member, only: [:edit, :update, :destroy, :resend_invitation]
            # rubocop:enable Rails/LexicallyScopedActionFilter

            def index
              enforce_permission_to :read, :space_member

              render template: "decidim/admin/members/index"
            end

            def new
              enforce_permission_to :create, :space_member
              @form = form(MemberForm).from_params({})
              render template: "decidim/admin/members/new"
            end

            def edit
              enforce_permission_to :update, :space_member, member: @member
              @form = form(MemberForm).from_model(@member)
              render template: "decidim/admin/members/edit"
            end

            def update
              enforce_permission_to :update, :space_member, member: @member
              @form = form(MemberForm).from_params(params)

              UpdateMember.call(@form, @member) do
                on(:ok) do
                  flash[:notice] = I18n.t("members.update.success", scope: "decidim.admin")
                  redirect_to action: :index
                end

                on(:invalid) do
                  flash.now[:alert] = I18n.t("members.update.error", scope: "decidim.admin")
                  render template: "decidim/admin/members/edit", status: :unprocessable_content
                end
              end
            end

            def create
              enforce_permission_to :create, :space_member
              @form = form(MemberForm).from_params(params)

              CreateMember.call(@form, current_participatory_space) do
                on(:ok) do
                  flash[:notice] = I18n.t("members.create.success", scope: "decidim.admin")
                  redirect_to action: :index
                end

                on(:invalid) do
                  flash.now[:alert] = I18n.t("members.create.error", scope: "decidim.admin")
                  render template: "decidim/admin/members/new", status: :unprocessable_content
                end
              end
            end

            def destroy
              enforce_permission_to :destroy, :space_member, member: @member

              DestroyMember.call(@member, current_user) do
                on(:ok) do
                  flash[:notice] = I18n.t("members.destroy.success", scope: "decidim.admin")
                  redirect_to after_destroy_path
                end

                on(:invalid) do
                  flash.now[:alert] = I18n.t("members.destroy.error", scope: "decidim.admin")
                  render template: "decidim/admin/members/index", status: :unprocessable_content
                end
              end
            end

            def resend_invitation
              enforce_permission_to :invite, :space_member, member: @member
              InviteUserAgain.call(@member.user, "invite_member") do
                on(:ok) do
                  flash[:notice] = I18n.t("users.resend_invitation.success", scope: "decidim.admin")
                end

                on(:invalid) do
                  flash[:alert] = I18n.t("users.resend_invitation.error", scope: "decidim.admin")
                end
              end

              redirect_to after_destroy_path
            end

            def publish_all
              PublishAllMembers.call(current_participatory_space, current_user) do
                on(:ok) do
                  flash[:notice] = I18n.t("members.publish_all.success", scope: "decidim.admin")
                  redirect_to action: :index
                end

                on(:invalid) do
                  flash[:alert] = I18n.t("members.publish_all.error", scope: "decidim.admin")
                  redirect_to action: :index
                end
              end
            end

            def unpublish_all
              UnpublishAllMembers.call(current_participatory_space, current_user) do
                on(:ok) do
                  flash[:notice] = I18n.t("members.unpublish_all.success", scope: "decidim.admin")
                  redirect_to action: :index
                end

                on(:invalid) do
                  flash[:alert] = I18n.t("members.unpublish_all.error", scope: "decidim.admin")
                  redirect_to action: :index
                end
              end
            end

            # Public: Returns a String or Object that will be passed to `redirect_to` after
            # destroying a member. By default it redirects to the participatory_space.
            #
            # It can be redefined at controller level if you need to redirect elsewhere.
            def after_destroy_path
              members_path(current_participatory_space)
            end

            def collection
              # there is an unidentified corner case where Decidim::User
              # may have been destroyed, but the related Member
              # remains in the database. That is why filtering by not null users
              @collection ||= current_participatory_space
                              .members
                              .includes(:user).where.not("decidim_users.id" => nil)
            end

            def members
              filtered_collection
            end

            def set_member
              @member = collection.find(params[:id])
            end
          end
        end
      end
    end
  end
end
