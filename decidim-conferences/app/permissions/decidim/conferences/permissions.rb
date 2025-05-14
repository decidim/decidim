# frozen_string_literal: true

module Decidim
  module Conferences
    class Permissions < Decidim::DefaultPermissions
      def permissions
        user_can_enter_space_area?

        return permission_action if conference && !conference.is_a?(Decidim::Conference)

        if read_admin_dashboard_action?
          user_can_read_admin_dashboard?
          return permission_action
        end

        if permission_action.scope == :public
          public_list_conferences_action?
          public_read_conference_action?
          public_list_speakers_action?
          public_list_program_action?
          public_list_media_links_action?
          public_list_registration_types_action?

          can_join_conference?
          can_leave_conference?
          can_decline_invitation?

          return permission_action
        end

        return permission_action unless user

        if !has_manageable_conferences? && !user.admin?
          disallow!
          return permission_action
        end
        return permission_action unless permission_action.scope == :admin

        user_can_read_conference_list?
        user_can_read_current_conference?
        user_can_read_conference_registrations?
        user_can_export_conference_registrations?
        user_can_confirm_conference_registration?
        user_can_create_conference?
        user_can_upload_images_in_conference?

        # org admins and space admins can do everything in the admin section
        org_admin_action?

        return permission_action unless conference

        moderator_action?
        collaborator_action?
        valuator_action?
        conference_admin_action?

        permission_action
      end

      private

      def can_join_conference?
        return unless conference.presence
        return unless conference.registrations_enabled? &&
                      permission_action.action == :join &&
                      permission_action.subject == :conference

        allow!
      end

      def can_leave_conference?
        return unless conference.presence
        return unless conference.registrations_enabled? &&
                      permission_action.action == :leave &&
                      permission_action.subject == :conference

        allow!
      end

      def can_decline_invitation?
        return unless user
        return unless conference.presence
        return unless conference.registrations_enabled? &&
                      conference.conference_invites.exists?(user:) &&
                      permission_action.action == :decline_invitation &&
                      permission_action.subject == :conference

        allow!
      end

      # It is an admin user if it is an organization admin or is a space admin
      # for the current `conference`.
      def admin_user?
        user.admin? || (conference ? can_manage_conference?(role: :admin) : has_manageable_conferences?)
      end

      # Checks if it has any manageable conference, with any possible role.
      def has_manageable_conferences?(role: :any)
        return unless user

        conferences_with_role_privileges(role).any?
      end

      # Whether the user can manage the given conference or not.
      def can_manage_conference?(role: :any)
        return unless user

        conferences_with_role_privileges(role).include? conference
      end

      # Returns a collection of conferences where the given user has the
      # specific role privilege.
      def conferences_with_role_privileges(role)
        Decidim::Conferences::ConferencesWithUserRole.for(user, role)
      end

      def public_list_conferences_action?
        return unless permission_action.action == :list &&
                      permission_action.subject == :conference

        allow!
      end

      def public_read_conference_action?
        return unless permission_action.action == :read &&
                      [:conference, :participatory_space].include?(permission_action.subject) &&
                      conference

        return allow! if user&.admin?
        return allow! if conference.published?

        toggle_allow(can_manage_conference?)
      end

      def public_list_speakers_action?
        return unless permission_action.action == :list &&
                      permission_action.subject == :speakers

        allow!
      end

      def public_list_program_action?
        return unless permission_action.action == :list &&
                      permission_action.subject == :program

        allow!
      end

      def public_list_media_links_action?
        return unless permission_action.action == :list &&
                      permission_action.subject == :media_links

        allow!
      end

      def public_list_registration_types_action?
        return unless permission_action.action == :list &&
                      permission_action.subject == :registration_types

        allow!
      end

      # All users with a relation to a conference and organization admins can enter
      # the space area. The space area is considered to be the conferences zone,
      # not the conference groups one.
      def user_can_enter_space_area?
        return unless permission_action.action == :enter &&
                      permission_action.scope == :admin &&
                      permission_action.subject == :space_area &&
                      context.fetch(:space_name, nil) == :conferences

        toggle_allow(user.admin? || has_manageable_conferences?)
      end

      # Checks if the permission_action is to read in the admin or not.
      def admin_read_permission_action?
        permission_action.action == :read
      end

      def read_admin_dashboard_action?
        permission_action.action == :read &&
          permission_action.subject == :admin_dashboard
      end

      # Any user that can enter the space area can read the admin dashboard.
      def user_can_read_admin_dashboard?
        allow! if user.admin? || has_manageable_conferences?
      end

      # Only organization admins can create a conference
      def user_can_create_conference?
        return unless permission_action.action == :create &&
                      permission_action.subject == :conference

        toggle_allow(user.admin?)
      end

      # Only organization admins can read a conference registrations
      def user_can_read_conference_registrations?
        return unless permission_action.action == :read_conference_registrations &&
                      permission_action.subject == :conference

        toggle_allow(user.admin?)
      end

      # Only organization admins can export a conference registrations
      def user_can_export_conference_registrations?
        return unless permission_action.action == :export_conference_registrations &&
                      permission_action.subject == :conference

        toggle_allow(user.admin?)
      end

      def user_can_confirm_conference_registration?
        return unless permission_action.action == :confirm &&
                      permission_action.subject == :conference_registration

        toggle_allow(user.admin?)
      end

      # Everyone can read the conference list
      def user_can_read_conference_list?
        return unless read_conference_list_permission_action?

        toggle_allow(user.admin? || has_manageable_conferences?)
      end

      def user_can_read_current_conference?
        return unless read_conference_list_permission_action?
        return if permission_action.subject == :conference_list

        toggle_allow(user.admin? || can_manage_conference?)
      end

      # A moderator needs to be able to read the conference they are assigned to,
      # and needs to perform all actions for the moderations of that conference.
      def moderator_action?
        return unless can_manage_conference?(role: :moderator)

        allow! if permission_action.subject == :moderation
      end

      # Collaborators can read/preview everything inside their conference.
      def collaborator_action?
        return unless can_manage_conference?(role: :collaborator)

        allow! if permission_action.action == :read || permission_action.action == :preview
      end

      # Valuators can only read components
      def valuator_action?
        return unless can_manage_conference?(role: :valuator)

        allow! if permission_action.action == :read && permission_action.subject == :component
        allow! if permission_action.action == :export && permission_action.subject == :component_data
      end

      # Process admins can perform everything *inside* that conference. They cannot
      # create a conference or perform actions on conference groups or other
      # conferences.
      def conference_admin_action?
        return unless can_manage_conference?(role: :admin)
        return if user.admin?
        return disallow! if permission_action.action == :create &&
                            permission_action.subject == :conference

        is_allowed = [
          :attachment,
          :attachment_collection,
          :category,
          :component,
          :component_data,
          :moderation,
          :conference,
          :conference_user_role,
          :conference_speaker,
          :partner,
          :media_link,
          :registration_type,
          :conference_invite
        ].include?(permission_action.subject)
        allow! if is_allowed
      end

      def org_admin_action?
        return unless user.admin?

        is_allowed = [
          :attachment,
          :attachment_collection,
          :category,
          :component,
          :component_data,
          :moderation,
          :conference,
          :conference_user_role,
          :conference_speaker,
          :media_link,
          :conference_invite,
          :partner,
          :registration_type,
          :read_conference_registrations,
          :export_conference_registrations
        ].include?(permission_action.subject)
        allow! if is_allowed
      end

      # Checks if the permission_action is to read the admin conferences list or
      # not.
      def read_conference_list_permission_action?
        permission_action.action == :read &&
          [:conference, :participatory_space, :conference_list].include?(permission_action.subject)
      end

      def conference
        @conference ||= context.fetch(:current_participatory_space, nil) || context.fetch(:conference, nil)
      end

      # Checks of assigned admins can upload images in the conference
      def user_can_upload_images_in_conference?
        allow! if user&.admin_terms_accepted? && user_has_any_role?(user, conference, broad_check: true) && (permission_action.subject == :editor_image)
      end
    end
  end
end
