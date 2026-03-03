# frozen_string_literal: true

require "spec_helper"

module Decidim::Budgets
  describe BudgetsListCell, type: :cell do
    controller Decidim::Budgets::BudgetsController

    let(:my_cell) { cell("decidim/budgets/budgets_list", current_workflow) }
    let(:current_workflow) { Workflows::All.new(component, user) }
    let!(:budgets) do
      [
        create(:budget, component:, weight: 0, total_budget: 20_000, title: Decidim::Faker::Localized.localized { "Higher cost" }),
        create(:budget, component:, weight: 1, total_budget: 10_000, title: Decidim::Faker::Localized.localized { "Lower cost" })
      ]
    end
    let(:component) { create(:budgets_component) }
    let(:participatory_space) { component.participatory_space }
    let(:organization) { participatory_space.organization }
    let(:user) { create(:user, organization:) }

    before do
      allow(controller).to receive(:current_component).and_return(component)
      allow(controller).to receive(:current_user).and_return(user)

      allow(my_cell).to receive(:url_for).and_return("/")

      # rubocop:disable Rspec/AnyInstance
      allow_any_instance_of(BudgetListItemCell).to receive(:budget_projects_path) do |_subcell, budget, **|
        "/budgets/#{budget.id}/projects"
      end
      # rubocop:enable Rspec/AnyInstance
    end

    describe "#main_list" do
      subject { Nokogiri::HTML(my_cell.main_list) }

      context "when ordering budgets" do
        let(:params) { ActionController::Parameters.new({ "order" => order_value, "component_id" => component.id }) }
        let(:order_value) { nil }
        let(:titles) { subject.css("h3").map { |node| node.text.strip } }

        before do
          allow(my_cell).to receive(:params).and_return(params)
        end

        context "with highest cost first" do
          let(:order_value) { "highest_cost" }

          it "orders the budgets correctly" do
            expect(titles).to eq(["Higher cost", "Lower cost"])
          end
        end

        context "with lowest cost first" do
          let(:order_value) { "lowest_cost" }

          it "orders the budgets correctly" do
            expect(titles).to eq(["Lower cost", "Higher cost"])
          end
        end

        context "with random order" do
          let(:order_value) { "random" }

          it "orders the budgets randomly" do
            expect(titles.count).to eq(2)
          end
        end
      end
    end
  end
end
