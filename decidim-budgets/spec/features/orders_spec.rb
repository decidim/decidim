# coding: utf-8
# frozen_string_literal: true
require "spec_helper"

describe "Orders", type: :feature do
  include_context "feature"
  let(:manifest_name) { "budgets" }

  let!(:user) { create :user, :confirmed, organization: organization }
  let!(:projects) { create_list(:project, 3, feature: feature, budget: 25_000_000) }
  let(:project) { projects.first }

  let!(:feature) do
    create(:budget_feature,
           :with_total_budget_and_vote_threshold_percent,
           manifest: manifest,
           participatory_process: participatory_process)
  end

  context "when the user is not logged in" do
    it "is given the option to sign in" do
      visit_feature

      within "#project-#{project.id}-item" do
        page.find('.budget--list__action').click
      end

      expect(page).to have_css('#loginModal', visible: true)
    end
  end

  context "when the user is logged in" do
    before do
      login_as user, scope: :user
      visit_feature
    end

    context "and has not a pending order" do
      it "adds a project to the current order" do
        within "#project-#{project.id}-item" do
          page.find('.budget--list__action').click
        end

        expect(page).to have_selector '.budget-list__data--added', count: 1

        expect(page).to have_content "ASSIGNED: €25,000,000"
        expect(page).to have_content "1 project selected"

        within ".budget-summary__selected" do
          expect(page).to have_content project.title[I18n.locale]
        end

        within "#order-progress .budget-summary__progressbox" do
          expect(page).to have_content "25%"
          expect(page).to have_selector("button.small:disabled")
        end
      end
    end

    context "and has pending order" do
      let!(:order) { create(:order, user: user, feature: feature) }
      let!(:line_item) { create(:line_item, order: order, project: project) }

      it "removes a project from the current order" do
        visit_feature
        expect(page).to have_content "ASSIGNED: €25,000,000"

        within "#project-#{project.id}-item" do
          page.find('.budget--list__action').click
        end

        expect(page).to have_content "ASSIGNED: €0"
        expect(page).not_to have_content "1 project selected"
        expect(page).not_to have_selector ".budget-summary__selected"

        within "#order-progress .budget-summary__progressbox" do
          expect(page).to have_content "0%"
        end

        expect(page).not_to have_selector '.budget-list__data--added'
      end

      context "and try to vote a project that exceed the total budget" do
        let!(:expensive_project) { create(:project, feature: feature, budget: 250_000_000) }

        it "cannot add the project" do
          visit_feature

          within "#project-#{expensive_project.id}-item" do
            page.find('.budget--list__action').click
          end

          expect(page).to have_css('#budget-excess', visible: true)
        end
      end

      context "and add another project exceeding vote threshold" do
        let!(:other_project) { create(:project, feature: feature, budget: 50_000_000) }

        it "can complete the checkout process" do
          visit_feature

          within "#project-#{other_project.id}-item" do
            page.find('.budget--list__action').click
          end

          expect(page).to have_selector '.budget-list__data--added', count: 2

          within "#order-progress .budget-summary__progressbox" do
            page.find('.button.small').click
          end

          expect(page).to have_css('#budget-confirm', visible: true)

          within "#budget-confirm" do
            page.find('.button.expanded').click
          end

          expect(page).to have_content("successfully")

          within "#order-progress .budget-summary__progressbox" do
            expect(page).not_to have_selector("button.small")
          end
        end
      end
    end

    context "and has a finished order" do
      let!(:order) { create(:order, user: user, feature: feature, checked_out_at: Time.current) }

      it "can cancel the order" do
        visit_feature

        within ".budget-summary" do
          page.find('.cancel-order').click
        end

        expect(page).to have_content("successfully")

        within "#order-progress .budget-summary__progressbox" do
          expect(page).to have_selector("button.small:disabled")
        end

        within ".budget-summary" do
          expect(page).not_to have_selector('.cancel-order')
        end
      end
    end
  end

  describe "show" do
    let!(:project) { create(:project, feature: feature, budget: 25_000_000) }

    before do
      visit decidim_budgets.project_path(
        id: project.id,
        participatory_process_id: participatory_process,
        feature_id: feature
      )
    end

    let(:attached_to) { project }
    it_behaves_like "has attachments"

    it "shows the feature" do
      expect(page).to have_i18n_content(project.title)
      expect(page).to have_i18n_content(project.description)
    end
  end
end
