# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Devise
    describe PagesController, type: :controller do
      routes { Decidim::Core::Engine.routes }

      let(:organization) { create :organization }

      before do
        request.env["decidim.current_organization"] = organization
      end

      context "when a template exists" do
        it "renders it" do
          get :show, params: { id: "home" }

          expect(response).to render_template(:home)
        end
      end

      context "when a page exists" do
        let(:page) { create(:static_page, organization: organization) }

        render_views

        it "renders the page contents" do
          get :show, params: { id: page.slug }

          expect(response).to render_template(:decidim_page)
          expect(controller.page).to eq(page)

          expect(response.body).to include(page.title[I18n.locale.to_s])
          expect(response.body).to include(page.content[I18n.locale.to_s])
        end
      end
    end
  end
end
