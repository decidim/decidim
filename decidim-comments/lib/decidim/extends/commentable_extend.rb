module CommentableExtend
  def users_to_notify_on_comment_created
    get_all_users_with_role
    super
  end

  def get_all_users_with_role
    participatory_process = feature.participatory_space
    admins = feature.organization.admins
    users_with_role = feature.organization.users_with_any_role
    process_users_with_role = get_user_with_process_role(participatory_process.id)
    users = admins + users_with_role + process_users_with_role
    users.uniq
  end

  def get_user_with_process_role(participatory_process_id)
    Decidim::ParticipatoryProcessUserRole.where(decidim_participatory_process_id: participatory_process_id).map(&:user)
  end

  # Public: Defines which users will receive a notification when a comment is authorized.
  def users_to_notify_on_comment_authorized
    Decidim::User.none
  end
end

Decidim::Comments::Commentable.module_eval { include CommentableExtend }