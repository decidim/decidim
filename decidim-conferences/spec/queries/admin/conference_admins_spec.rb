# frozen_string_literal: true

require "spec_helper"

module Decidim::Conferences
  describe Admin::AdminUsers do
    subject { described_class.new(conference) }

    let(:organization) { create :organization }
    let!(:conference) { create :conference, organization: }
    let!(:admin) { create(:user, :admin, :confirmed, organization:) }
    let!(:conference_admin_role) { create(:conference_user_role, conference:, user: conference_admin) }
    let(:conference_admin) { create(:user, organization:) }
    let!(:other_conference_admin_role) { create(:conference_user_role, user: other_conference_admin) }
    let(:other_conference_admin) { create(:user, organization:) }
    let!(:normal_user) { create(:user, :confirmed, organization:) }
    let!(:other_organization_user) { create(:user, :confirmed) }

    it "returns the organization admins and conference admins" do
      expect(subject.query).to match_array([admin, conference_admin])
    end

    context "when asking for organization admin users" do
      subject { described_class.new(nil, organization) }

      it "returns all the organization admins and conference admins" do
        expect(subject.query).to match_array([admin, conference_admin, other_conference_admin])
      end
    end
  end
end
