# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe UsersController, type: :controller do
    routes { Decidim::Core::Engine.routes }

    let(:organization) { create(:organization) }

    let(:user) { create(:user, :confirmed, organization: organization) }
    let(:params) { { id: user.id } }

    before do
      request.env["decidim.current_organization"] = organization
    end

    describe "GET users in json format" do
      context "when there are no results" do
        it "returns an empty json array" do
          get :index, format: :json, params: params.merge!(term: "#0")
          expect(response.body).to eq([].to_json)
        end
      end

      context "when searching by name" do
        it "returns the id, name and nickname for filtered users" do
          params[:term] = user.name.to_s
          get :index, format: :json, params: params
          expect(response.body).to eq("[[#{user.id},\"#{user.name}\",\"#{user.nickname}\"]]")
        end
      end

      context "when searching by nickname" do
        it "returns the id, name and nickname for filtered users" do
          params[:term] = "@#{user.nickname}"
          get :index, format: :json, params: params
          expect(response.body).to eq("[[#{user.id},\"#{user.name}\",\"#{user.nickname}\"]]")
        end
      end
    end
  end
end
