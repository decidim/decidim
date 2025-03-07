# frozen_string_literal: true

require "spec_helper"
require_relative "../shared/api_authenticatable_examples"

RSpec.describe "Api authentication", type: :request do
  let(:sign_in_path) { "/api/sign_in" }
  let(:sign_out_path) { "/api/sign_out" }
  let(:organization) { create(:organization) }
  let(:query) { "{session { user { id nickname } } }" }

  before do
    host! organization.host
  end

  context "with api user" do
    let(:key) { "dummykey123456" }
    let(:secret) { "decidim123456789" }
    let!(:user) { create(:api_user, organization: organization, api_key: key, api_secret: secret) }
    let(:params) do
      {
        api_user: {
          key: key,
          secret: secret
        }
      }
    end
    let(:hacker_key) { "fakekey123456" }
    let(:invalid_params) do
      {
        api_user: {
          key: hacker_key,
          secret: "incorrectsecret"
        }
      }
    end

    it_behaves_like "api authenticatable user"
  end

  context "with normal user" do
    let(:password) { "decidim123456789" }
    let!(:user) { create(:user, :confirmed, organization: organization, password: ) }
    let(:params) do
      {
        user: {
          email: user.email,
          password:
        }
      }
    end
    let(:hacker_key) { user.email }
    let(:hacker_password) { "fakekey123456" }
    let(:invalid_params) do
      {
        user: {
          email: user.email,
          password: hacker_password
        }
      }
    end

    it_behaves_like "api authenticatable user"
  end
end
