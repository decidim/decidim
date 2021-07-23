# frozen_string_literal: true

require "spec_helper"

module Decidim::Budgets
  describe ProjectMCell, type: :cell do
    controller Decidim::Budgets::ProjectsController

    subject { cell_html }

    let(:component) { create(:budgets_component) }
    let!(:project) { create(:project, component: component) }
    let(:model) { project }
    let(:cell_html) { cell("decidim/budgets/project_m", project, context: { show_space: show_space }).call }

    it_behaves_like "has space in m-cell"

    context "when rendering" do
      let(:show_space) { false }

      it "renders the card" do
        expect(subject).to have_css(".card--project")
      end

      context "when comments are blocked" do
        let(:component) { create(:budgets_component, :with_comments_disabled) }

        it "doesn't renders comments" do
          expect(subject).not_to have_css(".comments-icon")
        end
      end
    end
  end
end
