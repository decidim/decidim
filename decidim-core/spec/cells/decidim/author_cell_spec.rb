# frozen_string_literal: true

require "spec_helper"

describe Decidim::AuthorCell, type: :cell do
  subject { my_cell.call }

  let(:my_cell) { cell("decidim/author", model) }
  let!(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, organization: organization) }
  let(:user_group) { create(:user_group, :verified) }
  let(:model) { Decidim::UserPresenter.new(user) }

  before do
    allow(my_cell).to receive(:user_signed_in?).and_return(false)
  end

  context "when rendering a user" do
    it "renders a User author card" do
      expect(subject).to have_css(".author-data")
    end
  end

  context "when rendering a user group" do
    let(:model) { Decidim::UserGroupPresenter.new(user_group) }

    it "renders a User_group author card" do
      expect(subject).to have_css(".author-data")
    end
  end

  context "when rendering an official author card" do
    let(:model) { Decidim::Proposals::OfficialAuthorPresenter.new }

    it "renders a Official author card" do
      expect(subject).to have_css(".author-data")
    end
  end
end
