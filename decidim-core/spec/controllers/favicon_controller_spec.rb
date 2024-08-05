# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe FaviconController do
    routes { Decidim::Core::Engine.routes }

    let!(:organization) { create(:organization) }

    before do
      request.env["decidim.current_organization"] = organization
    end

    describe "GET show" do
      context "when the domain does not have an organization" do
        let!(:organization) { nil }

        it "renders empty favicon" do
          get :show

          expect(response).to have_http_status(:ok)
          expect(response.body).to be_empty
        end
      end

      context "when the organization does not have a favicon" do
        let!(:organization) { create(:organization, favicon: nil) }

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

        it "renders the favicon" do
          get :show

          expect(response).to have_http_status(:ok)
          expect(response.body).not_to be_empty
        end

        it "returns the correct cache headers" do
          get :show

          expect(response.headers["Cache-Control"]).to eq("max-age=604800, public")
          expect(response.headers["Last-Modified"]).to eq(organization.favicon.blob.created_at.httpdate)
          expect(response.headers["ETag"]).not_to be_empty
        end

        context "with a consecutive request" do
          it "returns the correct HTTP code and the same ETag" do
            get :show
            etag = response.headers["ETag"]

            request.headers["If-Modified-Since"] = organization.favicon.blob.created_at.httpdate
            request.headers["If-None-Match"] = etag
            get :show

            expect(response.headers["ETag"]).to eq(etag)
            expect(response).to have_http_status(:not_modified)
          end
        end

        context "and the variant has not been processed" do
          let(:favicon_path) { Decidim::Dev.asset("icon.png") }

          it "renders the processed favicon" do
            get :show

            expect(response).to have_http_status(:ok)
            expect(response.body).not_to be_empty
          end
        end

        context "and the variant has been processed" do
          let(:favicon_path) { Decidim::Dev.asset("icon.png") }

          before { organization.attached_uploader(:favicon).variant(:favicon).processed }

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
