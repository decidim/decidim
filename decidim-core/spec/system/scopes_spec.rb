# frozen_string_literal: true

require "spec_helper"

describe "Scopes picker", type: :system do
  let(:organization) { create(:organization) }
  let(:other_organization) { create(:organization) }
  let!(:scopes) { create_list(:scope, 3, organization:) }
  let!(:subscope) { create(:subscope, parent: scopes.first) }
  let!(:other_scopes) { create_list(:scope, 3, organization: other_organization) }

  describe "scope picker page" do
    before do
      switch_to_host(organization.host)
      visit decidim.scopes_picker_path(params)
    end

    let(:params) { { title: } }
    let(:title) { "A strange title" }

    it "shows given title" do
      expect(page).to have_content("A strange title")
    end

    context "when a scope is required" do
      let(:params) { { title:, required: true } }

      it "does not allow to choose current scope (none)" do
        expect(page).to have_selector(".scope-picker.picker-footer .buttons a.button[disabled='true']")
      end

      it "shows organization top scopes in content" do
        scopes.each do |scope|
          expect(page).to have_css(".scope-picker.picker-content li a", text: scope.name["en"])
        end
      end

      it "does not show other organization top scopes in content" do
        other_scopes.each do |scope|
          expect(page).not_to have_css(".scope-picker.picker-content li a", text: scope.name["en"])
        end
      end

      context "when has a current scope" do
        let(:params) { { title:, required: true, current: scopes.first } }

        it "allows to choose it" do
          expect(page).to have_no_selector(".scope-picker.picker-footer .buttons a.button[disabled='true']")
        end
      end
    end

    context "when has a current scope" do
      let(:params) { { title:, current: } }
      let(:current) { scopes.first }

      it "shows current scope in header" do
        expect(page).to have_css(".scope-picker.picker-header li a", text: current.name["en"])
      end

      it "shows global scope in header" do
        expect(page).to have_css(".scope-picker.picker-header li a", text: "Global scope")
      end
    end

    context "when has a root scope" do
      let(:params) { { title:, root: } }
      let(:root) { scopes.first }

      it "does not show global scope in header" do
        expect(page).to have_no_css(".scope-picker.picker-header li a", text: "Global scope")
      end

      it "shows root scope in header" do
        expect(page).to have_css(".scope-picker.picker-header li a", text: root.name["en"])
      end

      it "does not show root sibling scope in header" do
        expect(page).to have_no_css(".scope-picker.picker-header li a", text: scopes.last.name["en"])
      end

      it "shows child scope in content" do
        expect(page).to have_css(".scope-picker.picker-content li a", text: subscope.name["en"])
      end

      context "when has a current scope" do
        let(:params) { { title:, root:, current: } }
        let(:root) { scopes.first }
        let(:current) { subscope }

        it "shows root scope in header" do
          expect(page).to have_css(".scope-picker.picker-header li a", text: root.name["en"])
        end

        it "shows current scope in header" do
          expect(page).to have_css(".scope-picker.picker-header li a", text: subscope.name["en"])
        end

        it "does not shows any scope in content" do
          expect(page).to have_no_css(".scope-picker.picker-content li")
        end
      end
    end
  end
end
