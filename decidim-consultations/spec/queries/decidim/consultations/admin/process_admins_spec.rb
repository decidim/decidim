# frozen_string_literal: true

require "spec_helper"

module Decidim::Consultations
  describe Admin::AdminUsers do
    subject { described_class.new(consultation) }

    let(:organization) { create :organization }
    let(:consultation) { create :consultation, organization: organization }
    let!(:admin) { create(:user, :admin, :confirmed, organization: organization) }

    it "returns the organization admins" do
      expect(subject.query).to match_array([admin])
    end
  end
end
