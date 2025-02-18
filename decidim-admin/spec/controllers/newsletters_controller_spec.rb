# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe NewslettersController do
      routes { Decidim::Admin::Engine.routes }

      let(:organization) { create(:organization) }
      let(:current_user) { create(:user, :admin, :confirmed, organization:) }
      let(:newsletter) { create(:newsletter, organization:) }

      before do
        request.env["decidim.current_organization"] = organization
        sign_in current_user, scope: :user
      end

      describe "POST deliver" do
        let(:params) do
          {
            id: newsletter.id,
            newsletter: { send_to_all_users: "1" }
          }
        end

        context "when delivery is successful" do
          before do
            allow(Decidim::Admin::NewsletterRecipients).to receive(:for).and_return([current_user])
          end

          it "sets a flash notice and redirects to index" do
            post(:deliver, params:)

            expect(flash[:notice]).to eq(I18n.t("newsletters.deliver.success", scope: "decidim.admin"))
            expect(response).to redirect_to(action: :index)
          end
        end

        context "when there are no recipients" do
          before do
            allow(Decidim::Admin::NewsletterRecipients).to receive(:for).and_return([])
          end

          it "sets a flash error and renders the select_recipients_to_deliver template" do
            post(:deliver, params:)

            expect(flash.now[:error]).to eq(I18n.t("newsletters.send.no_recipients", scope: "decidim.admin"))
            expect(response).to render_template(:select_recipients_to_deliver)
          end
        end

        context "when the delivery is invalid" do
          let(:form_instance) { Decidim::Admin::SelectiveNewsletterForm.new }

          before do
            allow(Decidim::Admin::SelectiveNewsletterForm).to receive(:from_params).and_return(form_instance)
            allow(form_instance).to receive(:valid?).and_return(false)
          end

          it "sets a flash error and renders the select_recipients_to_deliver template" do
            post(:deliver, params:)

            expect(flash.now[:error]).to eq(I18n.t("newsletters.deliver.error", scope: "decidim.admin"))
            expect(response).to render_template(:select_recipients_to_deliver)
          end
        end
      end

      describe "GET confirm_recipients" do
        let!(:recipients) { create_list(:user, 3, organization:) }

        before do
          allow(Decidim::Admin::NewsletterRecipients).to receive(:for).and_return(User.where(id: recipients.map(&:id)))
          allow(controller).to receive(:paginate).and_call_original
        end

        it "assigns the recipients and paginates them" do
          get :confirm_recipients, params: { id: newsletter.id, newsletter: { send_to_all_users: "1" } }

          expect(assigns(:recipients)).to match_array(recipients)
          expect(response).to render_template(:confirm_recipients)
        end
      end

      describe "GET select_recipients_to_deliver" do
        context "when newsletter_params are present" do
          let(:params) do
            {
              id: newsletter.id,
              newsletter: {
                send_to_all_users: "1",
                send_to_participants: "0",
                participatory_space_types: {
                  participatory_processes: { manifest_name: "participatory_processes" },
                  assemblies: { manifest_name: "assemblies" }
                }
              }
            }
          end

          it "assigns the form with the given params" do
            get(:select_recipients_to_deliver, params:)

            assigned_form = assigns(:form)
            expect(assigned_form).to be_a(Decidim::Admin::SelectiveNewsletterForm)
            expect(assigned_form.send_to_all_users).to be true
            expect(assigned_form.send_to_participants).to be false
            expect(response).to render_template(:select_recipients_to_deliver)
          end
        end

        context "when newsletter_params are not present" do
          it "assigns the form from the newsletter model" do
            get :select_recipients_to_deliver, params: { id: newsletter.id }

            assigned_form = assigns(:form)
            expect(assigned_form).to be_a(Decidim::Admin::SelectiveNewsletterForm)
            expect(assigned_form.participatory_space_types).to be_present
            expect(response).to render_template(:select_recipients_to_deliver)
          end
        end
      end

      describe "GET recipients_count" do
        let(:params) { { id: newsletter.id, newsletter: { send_to_all_users: "1" } } }

        before do
          allow(controller).to receive(:recipients_count_query).and_return(5)
        end

        it "renders the recipients count as plain text" do
          get(:recipients_count, params:)

          expect(response.body).to eq("5")
          expect(response.content_type).to eq("text/plain; charset=utf-8")
        end
      end
    end
  end
end
