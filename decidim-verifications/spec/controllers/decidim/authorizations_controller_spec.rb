# frozen_string_literal: true

require "spec_helper"

module Decidim::Verifications
  describe AuthorizationsController, type: :controller do
    routes { Decidim::Verifications::Engine.routes }

    let(:user) { create(:user, :confirmed) }

    before do
      request.env["decidim.current_organization"] = user.organization
      sign_in user, scope: :user
    end

    describe "handler" do
      it "injects the current_user" do
        controller.params[:handler] = "dummy_authorization_handler"
        expect(controller.send(:handler).user).to eq(user)
      end
    end

    describe "POST create" do
      context "when the handler is valid" do
        let(:handler_name) { "dummy_authorization_handler" }
        let(:document_number) { "12345678X" }
        let(:handler_params) { { document_number: } }
        let(:authorization) { Decidim::Authorization.find_by(name: handler_name, user:) }

        it "creates an authorization and redirects the user" do
          expect do
            post :create, params: {
              handler: "dummy_authorization_handler",
              authorization_handler: handler_params
            }
          end.to change(Decidim::Authorization, :count).by(1)

          expect(authorization).not_to be_blank
          expect(flash[:notice]).to eq("You've been successfully authorized.")
          expect(response).to redirect_to(authorizations_path)
        end

        context "with a duplicate authorization" do
          let!(:duplicate_authorization) { create(:authorization, :granted, user: other_user, unique_id: document_number, name: handler_name) }
          let!(:other_user) { create(:user, organization: user.organization) }

          it "fails to create an authorization and renders the new action" do
            expect do
              post :create, params: {
                handler: "dummy_authorization_handler",
                authorization_handler: handler_params
              }
            end.not_to change(Decidim::Authorization, :count)

            expect(authorization).to be_blank
            expect(flash[:alert]).to eq("There was a problem creating the authorization.")
            expect(response).to render_template(:new)
          end

          context "when the duplicate authorization user is deleted" do
            let!(:other_user) { create(:user, :deleted, organization: user.organization) }

            it "transfers the authorization and redirects the user" do
              expect do
                post :create, params: {
                  handler: "dummy_authorization_handler",
                  authorization_handler: handler_params
                }
              end.not_to change(Decidim::Authorization, :count)

              expect(authorization).not_to be_blank
              expect(flash[:notice]).to eq("You've been successfully authorized.")
              expect(response).to redirect_to(authorizations_path)
            end

            context "and the source user had records to be transferred" do
              let(:component) { create(:component, manifest_name: "dummy", organization: user.organization) }
              let(:registry) { Decidim::BlockRegistry.new }

              before do
                allow(Decidim::AuthorizationTransfer).to receive(:registry).and_return(registry)

                registry.register(:dummy) do |tr|
                  tr.move_records(Decidim::DummyResources::DummyResource, :decidim_author_id)
                end

                create_list(:dummy_resource, 5, author: other_user, component:)
              end

              it "transfers the authorization and the records" do
                expect do
                  post :create, params: {
                    handler: "dummy_authorization_handler",
                    authorization_handler: handler_params
                  }
                end.not_to change(Decidim::Authorization, :count)

                expect(authorization).not_to be_blank
                expect(flash[:notice]).to eq(
                  <<~HTML
                    <p>#{CGI.escapeHTML("You've been successfully authorized.")}</p>
                    <p>We have recovered the following participation data based on your authorization:</p>
                    <ul><li>Dummy resource: 5</li></ul>
                  HTML
                )
                expect(response).to redirect_to(authorizations_path)
              end
            end
          end
        end
      end

      context "when the handler is not valid" do
        it "redirects the user" do
          post :create, params: { handler: "foo" }
          expect(response).to redirect_to(authorizations_path)
        end
      end
    end

    describe "GET new" do
      context "when the handler is not valid" do
        it "redirects the user" do
          get :new, params: { handler: "foo" }
          expect(response).to redirect_to(authorizations_path)
        end
      end
    end
  end
end
