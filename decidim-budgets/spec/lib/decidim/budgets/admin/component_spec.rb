# frozen_string_literal: true

require "spec_helper"

describe "Budgets component" do # rubocop:disable RSpec/DescribeClass
  let!(:component) { create(:budgets_component) }
  let(:organization) { component.organization }
  let!(:current_user) { create(:user, :confirmed, :admin, organization: organization) }

  describe "on update" do
    let(:manifest) { component.manifest }
    let(:participatory_space) { component.participatory_space }

    let(:form) do
      Decidim::Budgets::Admin::ComponentForm.from_params(
        id: component.id,
        weight: 0,
        manifest: manifest,
        participatory_space: participatory_space,
        name: generate_localized_title,
        default_step_settings: {},
        settings: new_settings(:global, settings)
      ).with_context(current_organization: organization)
    end

    let(:percent_enabled) { false }
    let(:percent) { 70 }
    let(:minimum_enabled) { false }
    let(:projects_enabled) { false }
    let(:minimum_number) { 3 }
    let(:maximum_number) { 6 }

    let(:settings) do
      {
        total_budget: 100_000_000,
        vote_rule_threshold_percent_enabled: percent_enabled,
        vote_threshold_percent: percent,
        vote_rule_minimum_budget_projects_enabled: minimum_enabled,
        vote_minimum_budget_projects_number: minimum_number,
        vote_rule_selected_projects_enabled: projects_enabled,
        vote_selected_projects_minimum: minimum_number,
        vote_selected_projects_maximum: maximum_number
      }
    end

    def new_settings(name, data)
      Decidim::Component.build_settings(manifest, name, data, organization)
    end

    describe "with minimum projects number to vote" do
      let(:minimum_enabled) { true }

      context "when the minimum projects number is valid" do
        it "updates the component" do
          expect do
            Decidim::Admin::UpdateComponent.call(form, component, current_user)
          end.to broadcast(:ok)
        end
      end

      context "when the minimum projects number is NOT valid" do
        let(:minimum_number) { 0 }

        it "does NOT update the component" do
          expect do
            Decidim::Admin::UpdateComponent.call(form, component, current_user)
          end.to broadcast(:invalid)
        end
      end
    end

    describe "with projects rule enabled" do
      let(:projects_enabled) { true }

      context "when the projects rule is valid" do
        it "updates the component" do
          expect do
            Decidim::Admin::UpdateComponent.call(form, component, current_user)
          end.to broadcast(:ok)
        end
      end

      context "when the projects rule is NOT valid" do
        let(:maximum_number) { 0 }

        it "does NOT update the component" do
          expect do
            Decidim::Admin::UpdateComponent.call(form, component, current_user)
          end.to broadcast(:invalid)
        end
      end

      context "when the maximum projects number is more than the minimum" do
        let(:maximum_number) { 4 }

        it "updates the component" do
          expect do
            Decidim::Admin::UpdateComponent.call(form, component, current_user)
          end.to broadcast(:ok)
        end
      end

      context "when the maximum projects number is less than the minimum" do
        let(:maximum_number) { 2 }

        it "does NOT update the component" do
          expect do
            Decidim::Admin::UpdateComponent.call(form, component, current_user)
          end.to broadcast(:invalid)
        end
      end
    end

    describe "with threshold percent enabled" do
      let(:percent_enabled) { true }

      context "when the threshold percent number is valid" do
        it "updates the component" do
          expect do
            Decidim::Admin::UpdateComponent.call(form, component, current_user)
          end.to broadcast(:ok)
        end
      end

      context "when the threshold percent is NOT valid" do
        let(:percent) { -1 }

        it "does NOT update the component" do
          expect do
            Decidim::Admin::UpdateComponent.call(form, component, current_user)
          end.to broadcast(:invalid)
        end
      end
    end

    describe "with more than one voting rule enabled" do
      let(:percent_enabled) { true }
      let(:minimum_enabled) { true }
      let(:projects_enabled) { true }

      it "does NOT update the component" do
        expect do
          Decidim::Admin::UpdateComponent.call(form, component, current_user)
        end.to broadcast(:invalid)
      end
    end

    describe "with no voting rule enabled" do
      let(:percent_enabled) { false }
      let(:minimum_enabled) { false }
      let(:projects_enabled) { false }

      it "does NOT update the component" do
        expect do
          Decidim::Admin::UpdateComponent.call(form, component, current_user)
        end.to broadcast(:invalid)
      end
    end
  end

  describe "on edit", type: :system do
    let(:edit_component_path) do
      Decidim::EngineRouter.admin_proxy(component.participatory_space).edit_component_path(component.id)
    end

    before do
      switch_to_host(organization.host)
      login_as current_user, scope: :user
    end

    describe "Budget component settings" do
      before do
        visit edit_component_path
      end

      context "when minimum projects rule is checked" do
        before do
          check "Enable rule: Minimum number of projects to be voted on"
        end

        it "is shown the number input" do
          expect(page).to have_content("Minimum number of projects to vote")
          expect(page).to have_css("input#component_settings_vote_minimum_budget_projects_number")
        end

        it "is hidden the percent input" do
          expect(page).to have_no_content("Vote threshold percent")
          expect(page).to have_no_css("input#component_settings_vote_threshold_percent")
        end

        it "is hidden the project rule inputs" do
          expect(page).to have_no_content("Minimum amount of projects to be selected")
          expect(page).to have_no_content("Maximum amount of projects to be selected")
          expect(page).to have_no_css("input#component_settings_vote_selected_projects_minimum")
          expect(page).to have_no_css("input#component_settings_vote_selected_projects_maximum")
        end
      end

      context "when projects rule is checked" do
        before do
          check "Enable rule: Minimum and maximum number of projects to be voted on"
        end

        it "is shown the number input" do
          expect(page).to have_content("Minimum amount of projects to be selected")
          expect(page).to have_content("Maximum amount of projects to be selected")
          expect(page).to have_css("input#component_settings_vote_selected_projects_minimum")
          expect(page).to have_css("input#component_settings_vote_selected_projects_maximum")
        end

        it "is hidden the percent input" do
          expect(page).to have_no_content("Vote threshold percent")
          expect(page).to have_no_css("input#component_settings_vote_threshold_percent")
        end

        it "is hidden the number input" do
          expect(page).to have_no_content("Minimum number of projects to vote")
          expect(page).to have_no_css("input#component_settings_vote_minimum_budget_projects_number")
        end
      end

      context "when threshold percent rule is checked" do
        before do
          check "Enable rule: Minimum budget percentage"
        end

        it "is shown the percent input" do
          expect(page).to have_content("Vote threshold percent")
          expect(page).to have_css("input#component_settings_vote_threshold_percent")
        end

        it "is hidden the number input" do
          expect(page).to have_no_content("Minimum number of projects to vote")
          expect(page).to have_no_css("input#component_settings_vote_minimum_budget_projects_number")
        end

        it "is hidden the project rule inputs" do
          expect(page).to have_no_content("Minimum amount of projects to be selected")
          expect(page).to have_no_content("Maximum amount of projects to be selected")
          expect(page).to have_no_css("input#component_settings_vote_selected_projects_minimum")
          expect(page).to have_no_css("input#component_settings_vote_selected_projects_maximum")
        end
      end
    end
  end

  describe "component projects exporter" do
    subject do
      component
        .manifest
        .export_manifests
        .find { |manifest| manifest.name == :projects }
        .collection
        .call(component, user)
    end

    let(:component) { create(:budgets_component) }
    let(:component2) { create(:budgets_component) }
    let(:budget) { create(:budget, component: component) }
    let(:budget2) { create(:budget, component: component2) }
    let(:budget3) { create(:budget, component: component2) }
    let!(:components_projects) { create_list(:project, 2, budget: budget) }
    let!(:another_component_projects) { create_list(:project, 3, budget: budget2) }
    let!(:another_component_projects2) { create_list(:project, 4, budget: budget3) }
    let(:organization) { component.participatory_space.organization }

    context "when the user is an admin" do
      let!(:user) { create :user, admin: true, organization: organization }

      it "exports all budgets from the component" do
        expect(subject.count).to eq(2)
        expect(subject).to match_array(components_projects)
      end
    end
  end

  describe "budget projects exporter" do
    subject do
      component
        .manifest
        .export_manifests
        .find { |manifest| manifest.name == :projects }
        .collection
        .call(component, user, budget1.id)
    end

    let(:component) { create(:budgets_component) }
    let(:budget1) { create(:budget, component: component) }
    let(:budget2) { create(:budget, component: component) }
    let!(:budget1_projects) { create_list(:project, 3, budget: budget1) }
    let!(:budget2_projects) { create_list(:project, 2, budget: budget2) }
    let(:organization) { component.participatory_space.organization }

    context "when the user is an admin" do
      let!(:user) { create :user, admin: true, organization: organization }

      it "exports projects of individual budget" do
        expect(subject.count).to eq(3)
      end
    end
  end
end
