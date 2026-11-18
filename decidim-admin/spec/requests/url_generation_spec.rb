# frozen_string_literal: true

require "spec_helper"

describe "Admin URL generation with untrusted parameters" do
  let(:organization) { create(:organization) }
  let(:admin) { create(:user, :admin, :confirmed, organization:) }
  let(:headers) { { "HOST" => organization.host } }

  before do
    # The pagination and the results per page selector are only rendered when
    # there is more than one page, and they are built from the request
    # parameters. Make sure they are present so this spec exercises them.
    create_list(:user, 30, :admin, :confirmed, organization:)
    login_as admin, scope: :user
  end

  it "does not use the script_name parameter to generate links" do
    get(
      "/en/admin/users?script_name=javascript:alert(1)//",
      headers:
    )

    expect(response).to have_http_status(:ok)
    expect(response.body).not_to match(/href="\s*javascript:/i)

    pagination = response.parsed_body.at("[data-pagination]")
    expect(pagination).to be_present

    page_two_link = pagination.css("a").find do |link|
      CGI.parse(URI.parse(link["href"]).query.to_s)["page"] == ["2"]
    end
    expect(page_two_link).to be_present

    page_two_url = URI.parse(page_two_link["href"])
    expect(page_two_url.path).to eq("/en/admin/users")
    expect(CGI.parse(page_two_url.query)).to include("page" => ["2"])
    expect(CGI.parse(page_two_url.query)).not_to have_key("script_name")
  end
end
