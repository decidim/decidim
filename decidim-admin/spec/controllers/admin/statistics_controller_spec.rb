# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe StatisticsController do
      routes { Decidim::Admin::Engine.routes }

      let(:organization) { create(:organization) }
      let(:user) { create(:user, :admin, :confirmed, organization:) }

      before do
        allow(controller).to receive(:current_organization).and_return(organization)
        sign_in user, scope: :user
      end

      describe "GET #index" do
        it "responds successfully" do
          get :index
          expect(response).to have_http_status(:ok)
        end

        it "enforces permission to read statistics" do
          expect(controller).to receive(:enforce_permission_to).with(:read, :statistics)
          get :index
        end

        it "initializes the statistics presenter" do
          get :index
          presenter = controller.send(:statistics_presenter)

          expect(presenter).to be_a(DashboardStatisticChartsPresenter)
        end

        it "sets the correct breadcrumb" do
          get :index
          breadcrumb = controller.send(:controller_breadcrumb_items).last

          expect(breadcrumb[:label]).to eq(I18n.t("menu.statistics", scope: "decidim.admin"))
          expect(breadcrumb[:url]).to eq("/admin/statistics")
          expect(breadcrumb[:active]).to be true
        end
      end
    end
  end
end
