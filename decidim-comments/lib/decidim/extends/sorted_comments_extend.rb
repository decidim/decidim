module SortedCommentsExtend
  def query
    scope = filter_comments

    scope = case @options[:order_by]
            when "older"
              order_by_older(scope)
            when "recent"
              order_by_recent(scope)
            when "best_rated"
              order_by_best_rated(scope)
            when "most_discussed"
              order_by_most_discussed(scope)
            else
              order_by_older(scope)
            end

    scope
  end
  def filter_comments
    if admin_or_moderator?
      Decidim::Comments::Comment
        .where(commentable: commentable)
        .not_hidden
        .includes(:author, :up_votes, :down_votes)
    else
      Decidim::Comments::Comment
        .where(commentable: commentable)
        .authorized
        .not_hidden
        .includes(:author, :up_votes, :down_votes)
    end
  end

  def current_user
    Thread.current[:current_user]
  end

  def admin_or_moderator?
    current_user &&
      (current_user.admin? ||
        @commentable.feature.organization.users_with_any_role.include?(current_user) || get_user_with_process_role(@commentable.feature.participatory_space.id).include?(current_user)
      )
  end

  def get_user_with_process_role(participatory_process_id)
    Decidim::ParticipatoryProcessUserRole.where(decidim_participatory_process_id: participatory_process_id).map(&:user)
  end
end

Decidim::Comments::SortedComments.class_eval do
  prepend(SortedCommentsExtend)
end

