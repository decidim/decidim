# frozen_string_literal: true

require "spec_helper"

describe Decidim::AuthorCell, type: :cell do
  subject { my_cell.call }

  controller Decidim::PagesController

  let(:my_cell) { cell("decidim/author", model) }
  let!(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, organization:) }
  let(:model) { Decidim::UserPresenter.new(user) }

  context "when rendering a user" do
    it "renders a User author card" do
      expect(subject).to have_css("[data-author]")
    end
  end

  context "when rendering an official author card" do
    let(:model) { Decidim::Proposals::OfficialAuthorPresenter.new }

    it "renders a Official author card" do
      expect(subject).to have_css("[data-author]")
    end
  end
end
