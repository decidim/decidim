# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe NewslettersController, type: :controller do
    routes { Decidim::Core::Engine.routes }

    let(:organization) { create :organization }

    before do
      request.env["decidim.current_organization"] = organization
    end

    describe "GET show" do
      context "when the newsletter is not send" do
        let(:newsletter) { create(:newsletter, organization: organization) }

        it "redirects to root path" do
          get :show, params: { id: newsletter.id }

          expect(response).to redirect_to(root_url(host: organization.host))
        end
      end

      context "when the newsletter is send" do
        let(:newsletter) { create(:newsletter, organization: organization, sent_at: Time.current) }

        it "renders the newsletter" do
          get :show, params: { id: newsletter.id }

          expect(response).to render_template(:show)
        end
      end
    end

    # describe "GET Unsubscribed" do
    #   let(:user_id) { 1 }
    #   let(:time) { Time.current - 2.days }
    #
    #   let(:params) do
    #     {
    #       u: sent_at_encrypted(user_id, time)
    #     }
    #   end
    #   let(:decrypted_string) { sent_at_decrypted(params[:u]) }
    #
    #   let(:sent_at_time) { Time.zone.at(decrypted_string.split("-").second.to_i)}
    #
    #   describe "when user click to unsubscribed" do
    #     context "and newsletter notifications is true" do
    #       let(:user) { create(:user, organization: organization, id: decrypted_string.first, newsletter_notifications: true) }
    #
    #       it "unsubscribe user if sent_at time is between today and 15 days before" do
    #         get :unsubscribe
    #
    #         expect(response).to render_template(:unsubscribed)
    #         expect(controller.flash.notice).to have_content("success")
    #       end
    #
    #       # it "not unsubscribe user" do
    #       #   get :unsubscribe
    #       #
    #       #   expect(response).to render_template(:unsubscribed)
    #       #   expect(controller.flash.notice).not_to have_content("success")
    #       # end
    #     end
    #
    #     # context "when newsletter notifications is false" do
    #     #   let(:user) { create(:user, organization: organization, id: decrypted_string.first, newsletter_notifications: false) }
    #     #
    #     #   it "redirects to notifications settings path" do
    #     #     get :unsubscribe
    #     #
    #     #     expect(response).to redirect_to(root_url(host: organization.host))
    #     #   end
    #     # end
    #   end
    # end
  end
end
