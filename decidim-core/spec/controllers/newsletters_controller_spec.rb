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

    describe "GET Unsubscribed" do
      let(:user_id) { "1" }

      describe "when user click to unsubscribed" do
        let(:encryptor) { Decidim::Encryptor }

        describe "when sent_at is between 15 days and today" do
          let(:decrypted_string) { encryptor.sent_at_decrypted(params[:u]) }
          let(:time) { (Time.current - 2.days).to_i }
          let(:sent_at_time) { Time.zone.at(decrypted_string.split("-").second.to_i) }

          context "and newsletter notifications is true" do
            let!(:user) { create(:user, organization: organization, id: user_id, newsletter_notifications: true) }

            it "unsubscribe user" do
              get :unsubscribe, params: { u: encryptor.sent_at_encrypted(user_id, time) }

              expect(response).to render_template(:unsubscribe)
              expect(controller.flash.notice).to have_content("success")
            end
          end

          context "and newsletter notifications is false" do
            let!(:user) { create(:user, organization: organization, id: user_id, newsletter_notifications: false) }

            it "not unsubscribe user" do
              get :unsubscribe, params: { u: encryptor.sent_at_encrypted(user_id, time) }

              expect(response).to render_template(:unsubscribe)
              expect(controller.flash.alert).to have_content("error")
            end
          end
        end

        describe "when sent_at is before than 15 days" do
          let(:decrypted_string) { encryptor.sent_at_decrypted(params[:u]) }
          let(:time) { (Time.current - 17.days).to_i }
          let(:sent_at_time) { Time.zone.at(decrypted_string.split("-").second.to_i) }

          it "say token has expired" do
            get :unsubscribe, params: { u: encryptor.sent_at_encrypted(user_id, time) }

            expect(response).to render_template(:unsubscribe)
            expect(controller.flash.alert).to have_content("expired")
          end
        end
      end
    end
  end
end
