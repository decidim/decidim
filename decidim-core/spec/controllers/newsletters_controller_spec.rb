# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe NewslettersController, type: :controller do
    routes { Decidim::Core::Engine.routes }

    let(:organization) { create :organization }

    describe "newsletter" do
      before do
        request.env["decidim.current_organization"] = organization
      end

      let(:newsletter) { create(:newsletter, organization: organization) }

      describe "GET show" do
        context "when the newsletter is not send" do
          it "redirects to root path" do
            get :show, params: { id: newsletter.id }

            expect(response).to redirect_to(root_url(host: organization.host))
          end
        end
      end
    end
  end
end
