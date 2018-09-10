module OrderExtend

  include Decidim::HasClassExtends

  def per_project
    component.settings.vote_per_project?
  end

  def limit_project_reached?
    return false unless per_project
    total_projects == number_of_projects
  end

  def total_projects
    projects.count
  end

  def remaining_projects
    number_of_projects - projects.count
  end

  def can_checkout?
    if component.settings.vote_per_project?
      limit_project_reached?
    else
      total_budget.to_f >= minimum_budget
    end
  end

  def number_of_projects
    component.settings.total_projects
  end

  def maximum_budget
    return 0 unless component || !per_project
    component.settings.total_budget.to_f
  end
end

Decidim::Budgets::Order.class_eval do
  prepend(OrderExtend)
end
