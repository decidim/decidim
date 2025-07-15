# frozen_string_literal: true

require "spec_helper"

describe "Doorkeeper authorizations" do
  include_context "with oauth application"

  describe "displaying the abilities" do
    context "with profile scope" do
      let(:scope) { "profile" }

      it "shows the correct abilities" do
        visit_oauth_authorization_page

        expect(page).to have_content(
          <<~TEXT
            This application will be able to:
            See your name
            See your nickname
            See your email
            This application will not be able to:
            Update your profile
            Read content through the API
            Publish content for you
          TEXT
        )
      end
    end

    context "with user scope" do
      let(:scope) { "user" }

      it "shows the correct abilities" do
        visit_oauth_authorization_page

        expect(page).to have_content(
          <<~TEXT
            This application will be able to:
            See your name
            See your nickname
            See your email
            Update your profile
            This application will not be able to:
            Read content through the API
            Publish content for you
          TEXT
        )
      end
    end

    context "with user and api:read scopes" do
      let(:scope) { "user api:read" }

      it "shows the correct abilities" do
        visit_oauth_authorization_page

        expect(page).to have_content(
          <<~TEXT
            This application will be able to:
            See your name
            See your nickname
            See your email
            Update your profile
            Read content through the API
            This application will not be able to:
            Publish content for you
          TEXT
        )
      end
    end

    context "with user, api:read and api:write scopes" do
      let(:scope) { "user api:read api:write" }

      it "shows the correct abilities" do
        visit_oauth_authorization_page

        expect(page).to have_content(
          <<~TEXT
            This application will be able to:
            See your name
            See your nickname
            See your email
            Update your profile
            Read content through the API
            Publish content for you
          TEXT
        )
        expect(page).to have_no_content("This application will not be able to:")
      end
    end

    context "with profile, user, api:read and api:write scopes" do
      let(:scope) { "profile user api:read api:write" }

      it "shows the correct abilities" do
        visit_oauth_authorization_page

        expect(page).to have_content(
          <<~TEXT
            This application will be able to:
            See your name
            See your nickname
            See your email
            Update your profile
            Read content through the API
            Publish content for you
          TEXT
        )
        expect(page).to have_no_content("This application will not be able to:")
      end
    end

    context "with no scope" do
      let(:scope) { "" }

      it "shows the abilities for the default scope" do
        visit_oauth_authorization_page

        expect(page).to have_content(
          <<~TEXT
            This application will be able to:
            See your name
            See your nickname
            See your email
            This application will not be able to:
            Update your profile
            Read content through the API
            Publish content for you
          TEXT
        )
      end
    end
  end

  describe "performing a regular OAuth sign in" do
    let(:token) { oauth_api_authorization("profile").split.last }

    it "can fetch token info" do
      uri = URI.parse("#{organization_host}/oauth/token/info?access_token=#{token}")
      request = Net::HTTP::Get.new(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      response = http.request(request)
      expect(response).to be_a(Net::HTTPOK)

      details = JSON.parse(response.body)
      expect(details).to match(
        a_hash_including(
          "resource_owner_id" => user.id,
          "scope" => %w(profile),
          "expires_in" => 7200,
          "application" => { "uid" => oauth_application.uid },
          "created_at" => an_instance_of(Integer)
        )
      )
    end

    it "can fetch details about the user" do
      uri = URI.parse("#{organization_host}/oauth/me?access_token=#{token}")
      request = Net::HTTP::Get.new(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      response = http.request(request)
      expect(response).to be_a(Net::HTTPOK)

      details = JSON.parse(response.body)
      expect(details).to match(
        a_hash_including(
          "id" => user.id,
          "email" => user.email,
          "name" => user.name,
          "nickname" => user.nickname,
          "image" => an_instance_of(String)
        )
      )
    end
  end

  describe "unauthorized" do
    it "responds with correct status code and empty data" do
      uri = URI.parse("#{organization_host}/oauth/me")
      request = Net::HTTP::Get.new(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      response = http.request(request)
      expect(response.code).to eq("401")
      expect(response.body).to eq("")
    end
  end
end
