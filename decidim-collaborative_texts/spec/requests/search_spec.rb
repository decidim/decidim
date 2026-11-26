# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Collaborative texts search" do
  let(:component) { create(:collaborative_text_component) }
  let(:organization) { component.organization }
  let(:search_term) { "doggo" }
  let(:search_path) { decidim.search_path(term: search_term, filter: { with_resource_type: "Decidim::CollaborativeTexts::Document" }) }

  before do
    3.times { |i| create(:collaborative_text_document, :published, component:, title: "A doggo collaborative text #{i}") }
  end

  it "preloads the document versions and coauthorships used by the cards" do
    queries = []
    callback = lambda do |_name, _start, _finish, _id, payload|
      queries << payload[:sql] unless payload[:cached] || payload[:name] == "SCHEMA"
    end

    ActiveSupport::Notifications.subscribed(callback, "sql.active_record") do
      get search_path, headers: { "HOST" => organization.host }
    end

    expect(response).to have_http_status(:ok)
    expect(queries.grep(/FROM "decidim_collaborative_texts_versions"/).size).to eq(1)
    expect(queries.grep(/FROM "decidim_coauthorships"/).size).to eq(1)
  end
end
