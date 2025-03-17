# frozen_string_literal: true

require "spec_helper"

describe Decidim::CoauthorshipsCell, type: :cell do
  subject { my_cell.call }

  controller Decidim::PagesController

  let(:my_cell) { cell("decidim/coauthorships", coauthorable) }
  let!(:organization) { create(:organization) }
  let!(:component) { create(:component, manifest_name: "dummy", organization:) }
  let(:coauthorable) { create(:coauthorable_dummy_resource, component:, authors_list: coauthors) }
  let(:user) { create(:user, :confirmed, organization:) }

  context "with User coauthorships" do
    let(:coauthors) { [user] }

    it "renders the User author" do
      expect(subject).to have_content(user.name)
    end
  end

  context "with Official coauthorships" do
    let(:coauthors) { [organization] }

    it "renders the Official author" do
      expect(subject).to have_content(Decidim::Dev::OfficialAuthorPresenter.new.name)
    end
  end

  context "with unresolveable coauthorships" do
    let(:coauthors) { [user] }

    before do
      coauthorable.present?
      user.destroy
      coauthorable.reload
    end

    it "renders with the NilPresenter" do
      expect(subject).to have_css("[data-author]")
    end
  end
end
