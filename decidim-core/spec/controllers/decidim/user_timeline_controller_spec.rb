# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe UserTimelineController, type: :controller do
    subject { get :index, params: { nickname: nickname } }

    routes { Decidim::Core::Engine.routes }

    let(:organization) { create(:organization) }
    let!(:user) { create(:user, :confirmed, nickname: "Nick", organization: organization) }
    let(:nickname) { "foobar" }

    before do
      request.env["decidim.current_organization"] = organization
    end

    shared_examples_for "a not found page" do
      it "raises an ActionController::RoutingError" do
        expect { subject }.to raise_error(ActionController::RoutingError, "Not Found")
      end
    end

    describe "#index" do
      context "with the user logged in" do
        before do
          sign_in user
        end

        context "with a different user than me" do
          it_behaves_like "a not found page"
        end

        context "with my user with uppercase" do
          let(:nickname) { user.nickname.upcase }

          it "returns the lowercased user" do
            subject

            expect(response).to render_template(:index)
          end
        end
      end

      context "without the user logged in" do
        context "with a non existing user" do
          it_behaves_like "a not found page"
        end

        context "with my user with uppercase" do
          let(:nickname) { user.nickname.upcase }

          it_behaves_like "a not found page"
        end
      end
    end
  end
end
