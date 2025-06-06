# frozen_string_literal: true

require "spec_helper"

describe "API OAuth" do
  let(:available_scopes) { "user api:read" }

  include_context "with oauth application"

  shared_examples "performs API queries with the assigned OAuth token" do
    let(:authorization) { oauth_api_authorization(token_scope) }
    let(:query) { "{ session { user { id name nickname } } }" }
    let(:graphql_data) do
      uri = URI.parse("#{organization_host}/api")
      request = Net::HTTP::Post.new(uri)
      request["Authorization"] = authorization
      request["Content-Type"] = "application/json; charset=utf-8"
      request["X-Jwt-Aud"] = oauth_application.uid
      request.body = { query: }.to_json

      http = Net::HTTP.new(uri.host, uri.port)
      response = http.request(request)
      raise "Invalid response from the API: #{response.code}" unless response.is_a?(Net::HTTPOK)
      raise "Unexpected content type from the API: #{response.content_type}" unless response.content_type == "application/json"

      details = JSON.parse(response.body)
      details["data"]
    end

    shared_context "with comment mutation" do
      let(:participatory_space) { create(:participatory_process, organization:) }
      let(:component) { create(:component, participatory_space:) }
      let(:model) { create(:dummy_resource, :published, component:) }
      let(:query) do
        %(
          mutation {
            commentable(
              id: "#{model.id}",
              type: "#{model.commentable_type}",
              locale: "en",
              toggleTranslations: false
            ) {
              addComment(body: "Test comment", alignment: 0) { body }
            }
          }
        )
      end
    end

    context "with user and api:read scopes" do
      let(:token_scope) { "user api:read" }

      it "shows the user details when authenticated with the API" do
        details = graphql_data.dig("session", "user")
        expect(details).to match(
          "id" => user.id.to_s,
          "name" => user.name,
          "nickname" => "@#{user.nickname}"
        )
      end

      context "when performing mutations" do
        include_context "with comment mutation"

        it "does not allow writing data through the API" do
          expect(graphql_data).to be_nil
        end
      end
    end

    context "with user scope" do
      let(:token_scope) { "user" }

      it "does not allow reading data through the API" do
        expect(graphql_data).to be_nil
      end

      context "when performing mutations" do
        include_context "with comment mutation"

        it "does not allow writing data through the API" do
          expect(graphql_data).to be_nil
        end
      end
    end

    context "with api:read scope" do
      let(:token_scope) { "api:read" }

      it "does not allow reading user data through the API" do
        expect(graphql_data).to match("session" => nil)
      end
    end

    context "with user, api:read and api:write scopes" do
      let(:token_scope) { "user api:read api:write" }

      include_context "with comment mutation"

      it "allows writing data through the API" do
        expect do
          expect(graphql_data).to match(
            "commentable" => { "addComment" => { "body" => "Test comment" } }
          )
        end.to change(Decidim::Comments::Comment, :count).by(1)
      end
    end
  end

  context "with a confidential OAuth client" do
    it_behaves_like "performs API queries with the assigned OAuth token"
  end

  context "with a public OAuth client" do
    let(:confidential) { false }

    it_behaves_like "performs API queries with the assigned OAuth token"
  end
end
