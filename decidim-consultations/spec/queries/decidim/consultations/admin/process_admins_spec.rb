# frozen_string_literal: true

require "spec_helper"

module Decidim::Consultations
  describe Admin::AdminUsers do
    subject { described_class.new(consultation) }

    let(:organization) { create :organization }
    let!(:consultation) { create :consultation, organization: }
    let!(:admin) { create(:user, :admin, :confirmed, organization:) }
    let!(:normal_user) { create(:user, :confirmed, organization:) }
    let!(:other_organization_user) { create(:user, :confirmed) }

    it "returns the organization admins" do
      expect(subject.query).to match_array([admin])
    end
  end
end
