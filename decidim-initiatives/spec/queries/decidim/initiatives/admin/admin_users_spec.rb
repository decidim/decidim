# frozen_string_literal: true

require "spec_helper"

module Decidim::Initiatives
  describe Admin::AdminUsers do
    subject { described_class.new(initiative) }

    let(:organization) { create :organization }
    let(:initiative) { create :initiative, :published, organization: organization }
    let!(:admin) { create(:user, :admin, :confirmed, organization: organization) }
    let!(:initiative_admin) do
      create(:user, :admin, :confirmed, organization: organization)
    end

    it "returns the organization admins and initiative admins" do
      expect(subject.query).to match_array([admin, initiative_admin])
    end
  end
end
