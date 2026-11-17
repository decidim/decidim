# frozen_string_literal: true

require "spec_helper"

describe "URL generation with untrusted parameters" do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, organization:) }
  let(:participatory_space) { create(:participatory_process, :published, organization:) }
  let!(:component) { create(:proposal_component, participatory_space:) }
  let!(:proposal) { create(:proposal, component:, published_at: Time.current) }
  let(:headers) { { "HOST" => organization.host } }

  before do
    create_list(
      :action_log,
      26,
      organization:,
      user:,
      participatory_space:,
      component:,
      resource: proposal,
      action: "publish",
      visibility: "public-only"
    )
  end

  it "does not use the script_name parameter to generate links" do
    get(
      "/en/last_activities?script_name=javascript:alert(1)//",
      headers:
    )

    expect(response).to have_http_status(:ok)
    expect(response.body).not_to match(/href="\s*javascript:/i)
    expect(response.body).to include("/en/last_activities?per_page=25")
    expect(response.body).to include("/en/last_activities?page=2")
  end

  it "ignores malformed _recall parameters when generating links" do
    get(
      "/en/last_activities?_recall=malformed",
      headers:
    )

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("/en/last_activities?per_page=25")
  end

  it "keeps the intended page and ignores a nested params[page] option" do
    get(
      "/en/last_activities?params[page]=99&page=2",
      headers:
    )

    expect(response).to have_http_status(:ok)

    pagination = response.parsed_body.at("[data-pagination]")
    expect(pagination.css('li[aria-current="page"]').text.strip).to eq("2")

    hrefs = pagination.css("a").map { |link| link["href"] }
    expect(hrefs).not_to include(a_string_matching(/params(%5B|\[)page/i))
    expect(hrefs).not_to include(a_string_including("page=99"))
  end
end
