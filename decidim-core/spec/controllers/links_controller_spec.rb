# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe LinksController, type: :controller do
    routes { Decidim::Core::Engine.routes }

    let(:organization) { create(:organization) }
    let(:external_url) { "https://example.org/test?foo=bar"}

    before do
      request.env["decidim.current_organization"] = organization
    end

    shared_examples "opens a page to proceed to the external link" do
      it "opens the open external link page without alerts" do
        expect(flash[:alert]).to be_nil
        expect(response).to have_http_status(:ok)
        expect(subject).to render_template(:new)
      end
    end

    describe "GET new" do
      subject { get :new, params: { external_url: } }

      before do
        subject
      end

      context "when the url has only ascii characters" do
        it_behaves_like "opens a page to proceed to the external link"
      end

      context "when the url has non ascii characters" do
        let(:external_url) { "https://example.org/test?foo=bàr"}

        it_behaves_like "opens a page to proceed to the external link"
      end

      context "when the url is invalid" do
        let(:external_url) { "not-an-url" }

        it "returns an invalid url alert" do
          expect(flash[:alert]).to eq("Invalid URL")
          expect(subject).to redirect_to("/")
        end
      end
    end
  end
end
