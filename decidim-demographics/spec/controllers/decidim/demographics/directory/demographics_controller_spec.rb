# frozen_string_literal: true

require "spec_helper"

describe Decidim::Demographics::Directory::DemographicsController, type: :controller do
  routes { Decidim::Demographics::DirectoryEngine.routes }

  let(:time_zone) { "UTC" }
  let(:organization) { create(:organization, time_zone: time_zone) }
  let(:user) { create :user, :admin, :confirmed, organization: organization }

  let(:params) do
    {
      demographic: {
        gender: "male",
        age: "< 15",
        nationalities: [:romanian]
      }
    }
  end

  before do
    request.env["decidim.current_organization"] = organization
    sign_in user
  end

  context "when new action" do
    it "tests new action" do
      get :new
      expect(response).to render_template("decidim/demographics/directory/demographics/new")
    end
  end

  context "when create action" do
    context "when create is ok" do
      before do
        post :create, params: params
      end

      it { expect(response).to redirect_to new_path }
      it { expect(flash[:notice]).to be_present }
    end

    context "when create is not ok" do
      let(:params) do
        {
          demographic: {
            valid: false
          }
        }
      end

      before do
        post :create, params: params
      end

      it "test creating failed" do
        expect(response).to render_template("decidim/demographics/directory/demographics/new")
      end

      it "shows the alert flash" do
        expect(flash.now[:alert]).to be_present
      end
    end
  end
end
