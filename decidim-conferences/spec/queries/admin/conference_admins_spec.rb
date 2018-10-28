# frozen_string_literal: true

require "spec_helper"

module Decidim::Conferences
  describe Admin::AdminUsers do
    subject { described_class.new(conference) }

    let(:organization) { create :organization }
    let(:conference) { create :conference, organization: organization }
    let!(:admin) { create(:user, :admin, :confirmed, organization: organization) }
    let!(:conference_admin) do
      create(:user, :admin, :confirmed, organization: organization)
    end

    it "returns the organization admins and conference admins" do
      expect(subject.query).to match_array([admin, conference_admin])
    end
  end
end
