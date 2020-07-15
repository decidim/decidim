# frozen_string_literal: true

class MoveBudgetsToOwnModel < ActiveRecord::Migration[5.2]
  class Component < ApplicationRecord
    self.table_name = :decidim_components
  end

  class Budget < ApplicationRecord
    self.table_name = :decidim_budgets_budgets
  end

  class Project < ApplicationRecord
    self.table_name = :decidim_budgets_projects
  end

  class Order < ApplicationRecord
    self.table_name = :decidim_budgets_orders
  end

  def up
    Project.reset_column_information
    Order.reset_column_information

    budget_components.each do |component|
      resource = create_budget_resource_from(component)

      if resource
        add_budget_references_to_projects(resource)
        add_budget_reference_to_orders(resource)
      end
    end

    remove_column :decidim_budgets_projects, :decidim_component_id
    remove_column :decidim_budgets_orders, :decidim_component_id
  end

  def down
    add_column :decidim_budgets_projects, :decidim_component_id
    add_column :decidim_budgets_orders, :decidim_component_id

    Budget.find_each do |resource|
      revert_budget_to_component(resource)
      if resource
        add_component_reference_to_projects(resource)
        add_component_reference_to_orders(resource)
      end
    end
  end

  # up methods
  def budget_components
    @budget_components ||= Component.where(manifest_name: "budgets")
  end

  def create_budget_resource_from(component)
    component_total_budget = (component["settings"]["global"]["total_budget"] if component["settings"]["global"].try(:key?, "total_budget"))

    Budget.create!(
      decidim_component_id: component.id,
      total_budget: component_total_budget,
      title: component.name
    )
  end

  def add_budget_references_to_projects(resource)
    # rubocop:disable Rails/SkipsModelValidations
    Project.where(decidim_component_id: resource.decidim_component_id)
           .update_all(decidim_budgets_budget_id: resource.id)
    # rubocop:enable Rails/SkipsModelValidations
  end

  def add_budget_reference_to_orders(resource)
    # rubocop:disable Rails/SkipsModelValidations
    Order.where(decidim_component_id: resource.decidim_component_id)
         .update_all(decidim_budgets_budget_id: resource.id)
    # rubocop:enable Rails/SkipsModelValidations
  end

  # down methods

  def revert_budget_to_component(resource)
    component = Component.find_by(id: resource.decidim_component_id, manifest_name: "budgets")
    component_settings = if resource.total_budget && component["settings"].try(:key?, "global")
                           component["settings"]["global"].merge!(total_budget: resource.total_budget)
                           component["settings"]
                         end

    component.update!(
      settings: component_settings,
      name: resource.title
    )
  end

  def add_component_reference_to_orders(resource)
    # rubocop:disable Rails/SkipsModelValidations
    Order.where(decidim_budgets_budget_id: resource.id)
         .update_all(decidim_component_id: resource.decidim_component_id)
    # rubocop:enable Rails/SkipsModelValidations
  end

  def add_component_reference_to_projects(resource)
    # rubocop:disable Rails/SkipsModelValidations
    Project.where(decidim_budgets_budget_id: resource.id)
           .update_all(decidim_component_id: resource.decidim_component_id)
    # rubocop:enable Rails/SkipsModelValidations
  end
end
