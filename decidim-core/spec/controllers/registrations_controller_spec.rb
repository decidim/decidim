# frozen_string_literal: true
require "spec_helper"

module Decidim
  describe Decidim::Devise::RegistrationsController, type: :controller do
    let(:organization) { create(:organization) }
    
    before do
      @request.env["decidim.current_organization"] = organization
    end
    
    describe "POST create" do
      let(:email) { "test@decidim.org" }
      let(:params) do
        {
          user: {
            sign_up_as: "user",
            name: "User",
            email: email,
            password: "password1234",
            password_confirmation: "password1234",            
            tos_agreement: "1"
          }
        }
      end
      
      context "when the user created is active for authentication" do
        before do
          expect_any_instance_of(Decidim::User)
            .to receive(:active_for_authentication?)
              .at_least(:once)
              .and_return(true)
          expect(controller).to receive(:sign_up).and_call_original
        end

        it "doesn't ask the user to confirm the email" do
          post :create, params: params
          expect(controller.flash.notice).not_to have_content("confirmation")
        end
      end

      context "when the form is invalid" do
        let(:email) { nil }

        it "should render the new template" do
          post :create, params: params        
          expect(controller).to render_template "new"
        end
      end
    end 
  end
end
