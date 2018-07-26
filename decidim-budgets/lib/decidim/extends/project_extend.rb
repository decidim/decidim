# frozen_string_literal: true

module ProjectExtend
  include Decidim::HasClassExtends

  def users_to_notify_on_comment_created
    users_with_role
  end
end

Decidim::Budgets::Project.class_eval do
  prepend(ProjectExtend)
end
