# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Project search" do
  include Decidim::ComponentPathHelper

  let(:user) { create(:user, :confirmed) }
  let(:participatory_space) { create(:participatory_process, :with_steps, organization: user.organization) }
  let(:component) { create(:budgets_component, participatory_space:, settings:) }
  let(:settings) { { vote_threshold_percent: 50 } }
  let(:budget) { create(:budget, component:, total_budget: 100_000) }
  let(:project) { create(:project, budget:, budget_amount: 60_000) }

  let(:headers) { { "HOST" => participatory_space.organization.host } }

  before do
    login_as user, scope: :user
  end

  describe "POST create" do
    let(:request_path) { Decidim::EngineRouter.main_proxy(component).budget_order_line_item_path(budget) }

    it "creates the order" do
      expect do
        post(request_path, xhr: true, params: { project_id: project.id }, headers:)
      end.to change(Decidim::Budgets::Order, :count).by(1)

      expect(response).to have_http_status(:ok)
    end

    context "when trying to add the same project twice" do
      it "adds it only once" do
        post(request_path, xhr: true, params: { project_id: project.id }, headers:)
        expect(response).to have_http_status(:ok)

        post(request_path, xhr: true, params: { project_id: project.id }, headers:)
        expect(response).to have_http_status(:unprocessable_entity)

        expect(Decidim::Budgets::Order.count).to eq(1)
        expect(Decidim::Budgets::LineItem.count).to eq(1)
      end
    end

    context "with concurrent requests" do
      include_context "with concurrency"

      before do
        # Persist the session cookie before the concurrent requests.
        get(Decidim::Core::Engine.routes.url_helpers.root_path, headers:)
      end

      it "only creates a single order" do
        expect do
          threads = 10.times.map do
            Thread.new do
              sleep(rand(0.05..0.5))

              post(request_path, xhr: true, params: { project_id: project.id }, headers:)
            end
          end
          # Wait for each thread to finish
          threads.each(&:join)
        end.not_to raise_error

        expect(Decidim::Budgets::Order.count).to eq(1)
      end
    end
  end
end
