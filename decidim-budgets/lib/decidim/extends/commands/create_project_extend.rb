# frozen_string_literal: true

module CreateProjectExtend
  def create_project
    @project = Decidim.traceability.create!(
      Decidim::Budgets::Project,
      @form.current_user,
      scope: @form.scope,
      category: @form.category,
      component: @form.current_component,
      title: @form.title,
      description: @form.description,
      budget: @form.budget,
      address: @form.address,
      latitude: @form.latitude,
      longitude: @form.longitude
    )
  end
end

Decidim::Budgets::Admin::CreateProject.class_eval do
  prepend(CreateProjectExtend)
end
