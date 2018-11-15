# frozen_string_literal: true

module UpdateProjectExtend
  def update_project
    Decidim.traceability.update!(
      project,
      form.current_user,
      scope: form.scope,
      category: form.category,
      title: form.title,
      description: form.description,
      budget: form.budget,
      address: form.address,
      latitude: form.latitude,
      longitude: form.longitude
    )
  end
end

Decidim::Budgets::Admin::UpdateProject.class_eval do
  prepend(UpdateProjectExtend)
end
