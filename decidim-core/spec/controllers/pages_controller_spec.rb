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

      context "when a page exists" do
        let(:page) { create(:static_page, organization: organization) }

        render_views

        it "renders the page contents" do
          get :show, params: { id: page.slug }

          expect(response).to render_template(:show)

          expect(response.body).to include(page.title[I18n.locale.to_s])
          expect(response.body).to include(page.content[I18n.locale.to_s])
        end

        context "when asking the page in other formats" do
          it "ignores them" do
            get :show, params: { id: page.slug }, format: :text

            expect(response).to render_template(:show)
          end
        end
      end

      context "when a page doesn't exist" do
        it "redirects to the 404" do
          expect { get :show, params: { id: "some-page" } }
            .to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "when a page doesn't exist" do
        it "redirects to the 404" do
          expect { get :show, params: { id: "some-page" } }
            .to raise_error(ActionController::RoutingError)
        end
      end
    end
  end
end
