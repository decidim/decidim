# frozen_string_literal: true

require "spec_helper"

module Decidim::Initiatives
  describe Admin::AdminUsers do
    subject { described_class.new(initiative) }

    let(:organization) { create :organization }
    let!(:initiative) { create :initiative, :published, organization: }
    let!(:admin) { create(:user, :admin, :confirmed, organization:) }
    let!(:normal_user) { create(:user, :confirmed, organization:) }
    let!(:other_organization_user) { create(:user, :confirmed) }

    it "returns the organization admins" do
      expect(subject.query).to match_array([admin])
    end
  end
end
