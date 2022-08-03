# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe FaviconController, type: :controller do
    routes { Decidim::Core::Engine.routes }

    let!(:organization) { create :organization }

    before do
      request.env["decidim.current_organization"] = organization
    end

    describe "GET show" do
      context "when the domain does not have an organization" do
        let!(:organization) { nil }

        it "renders empty favicon before it has been processed" do
          get :show

          expect(response).to have_http_status(:ok)
          expect(response.body).to be_empty
        end
      end

      context "when the organization does not have a favicon" do
        it "renders empty favicon before it has been processed" do
          get :show

          expect(response).to have_http_status(:ok)
          expect(response.body).to be_empty
        end
      end

      context "when the organization has a favicon" do
        let(:favicon_path) { Decidim::Dev.asset("icon.ico") }

        before do
          organization.favicon.attach(io: File.open(favicon_path), filename: File.basename(favicon_path))
          organization.save!
        end

        it "renders empty favicon before it has been processed" do
          get :show

          expect(response).to have_http_status(:ok)
          expect(response.body).to be_empty
        end

        context "and the variant has been processed" do
          before { organization.attached_uploader(:favicon).variant(:favicon).process }

          it "renders the favicon" do
            get :show

            expect(response).to have_http_status(:ok)
            expect(response.body).not_to be_empty
          end
        end
      end
    end
  end
end
