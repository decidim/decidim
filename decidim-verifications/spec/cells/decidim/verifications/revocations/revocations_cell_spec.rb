# frozen_string_literal: true

require "spec_helper"

module Decidim::Verifications
  describe RevocationsCell, type: :cell do
    controller Decidim::Admin::AuthorizationWorkflowsController

    let(:name) { "some_method" }
    let(:prev_year) { Date.today.prev_year }
    let(:organization) { create :organization }
    let(:user1) { create(:user, organization: organization) }
    let(:user2) { create(:user, organization: organization) }
    let(:user3) { create(:user, organization: organization) }
    let!(:granted_authorizations) do
      create(:authorization, created_at: prev_year, granted_at: prev_year, name: name, user: user1)
      create(:authorization, created_at: prev_year, granted_at: prev_year, name: name, user: user2)
      create(:authorization, created_at: prev_year, granted_at: prev_year, name: name, user: user3)
    end
    let(:authorizations) do
      Decidim::Verifications::Authorizations.new(
          organization: organization,
          user: user1,
          name: name,
          granted: true
      ).query
    end
    let(:params) { }

    context "when rendering with granted authorizations" do
      it "renders the cell" do
        html = cell("decidim/verifications/revocations", authorizations).call
        expect(html).to have_css(".revoke_all_box")
        expect(html).to have_css(".revoke_before_date_box")
      end
      it "renders the revoke all box" do
        html = cell("decidim/verifications/revocations", authorizations).call
        expect(html).to have_css(".revoke_all_box")
      end
      it "renders the revoke before date box" do
        html = cell("decidim/verifications/revocations", authorizations).call
        expect(html).to have_css(".revoke_before_date_box")
      end
    end

    context "when rendering with ungranted authorizations" do
      let(:no_authorizations) do
        Decidim::Verifications::Authorizations.new(
            organization: organization,
            user: nil,
            name: nil,
            granted: false
        ).query
      end
      it "renders the cell without authorizations warning" do
        html = cell("decidim/verifications/revocations", no_authorizations).call
        expect(html).not_to have_css(".revoke_all_box")
        expect(html).not_to have_css(".revoke_before_date_box")
        expect(html).to have_css(".revoke_no_data")
      end
    end

  end
end
