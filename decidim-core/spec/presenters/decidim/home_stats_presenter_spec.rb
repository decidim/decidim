# frozen_string_literal: true
require "spec_helper"

module Decidim
  describe HomeStatsPresenter do
    subject { described_class.new(organization: organization) }

    let!(:organization) { create(:organization) }

    before do
      allow(Decidim).to receive(:stats).and_return({
        foo: { primary: true, block: Proc.new { 10 } },
        bar: { primary: true, block: Proc.new { 20 } },
        foz: { primary: false, block: Proc.new { 30 } },
        baz: { primary: false, block: Proc.new { 40 } }
      })
      I18n.backend.store_translations(:en, {
        pages: {
          home: {
            statistics: {
              foo: "Foo",
              bar: "Bar",
              foz: "Foz",
              baz: "Baz"
            }
          }
        }
      })
    end

    describe "#highlighted" do
      it "renders a collection of primary stats" do
        expect(subject.highlighted).to eq("<div class=\"home-pam__data\"><h4 class=\"home-pam__title\">Foo</h4><span class=\"home-pam__number foo\"> 10</span></div><div class=\"home-pam__data\"><h4 class=\"home-pam__title\">Bar</h4><span class=\"home-pam__number bar\"> 20</span></div>")
      end
    end

    describe "#not_highlighted" do
      it "renders a collection of not primary stats" do
        expect(subject.not_highlighted).to eq("<div class=\"home-pam__data\"><h4 class=\"home-pam__title\">Foz</h4><span class=\"home-pam__number foz\"> 30</span></div><div class=\"home-pam__data\"><h4 class=\"home-pam__title\">Baz</h4><span class=\"home-pam__number baz\"> 40</span></div>")
      end
    end

    describe "#users_count" do
      before do
        create_list(:user, 3, organization: organization)
      end

      it "renders the number of users for this organization" do
        expect(subject.users_count).to eq("<div class=\"home-pam__data\"><h4 class=\"home-pam__title\">Users</h4><span class=\"home-pam__number users_count\"> 3</span></div>")
      end
    end

    describe "#processes_count" do
      before do
        create_list(:participatory_process, 3, organization: organization)
        ParticipatoryProcess.last.update_attributes(published_at: false)
      end

      it "renders the number of published processes for this organization" do
        expect(subject.processes_count).to eq("<div class=\"home-pam__data\"><h4 class=\"home-pam__title\">Processes</h4><span class=\"home-pam__number processes_count\"> 2</span></div>")
      end
    end
  end
end
