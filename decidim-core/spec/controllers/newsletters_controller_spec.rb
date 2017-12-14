# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe NewslettersController, type: :controller do
    routes { Decidim::Core::Engine.routes }

    let(:organization) { create :organization }

    before do
      request.env["decidim.current_organization"] = organization
    end

    context "when a newsletter was send" do
      let(:newsletter) { create(:newsletter, organization: organization, sent_at: Time.zone) }

      render_views

      it "renders the newsletter" do
        get :show, params: { id: newsletter.id }

        expect(response).to render_template(:show)
        expect(controller.newsletter).to eq(newsletter)

        expect(response.body).to include(newsletter.body[I18n.locale.to_s])
      end
    end
  end
end
