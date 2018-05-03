# frozen_string_literal: true

require "spec_helper"

describe Decidim::AuthorCell, type: :cell do
  let!(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, organization: organization) }
  let(:user_group) { create(:user_group, :verified) }

  it "renders a User author card" do
    html = cell("decidim/author", Decidim::UserPresenter.new(user)).call
    expect(html).to have_css(".author-data")
  end

  it "renders a User_group author card" do
    html = cell("decidim/author", Decidim::UserGroupPresenter.new(user_group)).call
    expect(html).to have_css(".author-data")
  end

  it "renders a Official author card" do
    html = cell("decidim/author", Decidim::Proposals::OfficialAuthorPresenter.new).call
    expect(html).to have_css(".author-data")
  end
end
