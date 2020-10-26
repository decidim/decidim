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
      nationalities: [:romanian],
      postal_code: "111222",
      background: "self-employed"
    }
  }
  end

  before do
    request.env["decidim.current_organization"] = organization
    sign_in user
  end

  context "new action" do 
 
    it "tests new action" do
      get :new
      expect(response).to render_template("decidim/demographics/directory/demographics/new")
    end
  end


  context "create action" do 

    before :each do 
      post :create, params: params
    end

    context "create is ok" do 

      it { expect(response).to redirect_to new_path }
      it { expect(flash[:notice]).to be_present }
    end

    context "create is not ok" do 
      before do
        allow(Decidim::Demographics::RegisterDemographicsData).to receive(:call).and_return(:invalid)
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
