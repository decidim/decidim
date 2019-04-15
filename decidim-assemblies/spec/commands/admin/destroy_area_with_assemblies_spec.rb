# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe DestroyArea do
    subject { described_class.new(area, user) }

    let(:organization) { create :organization }
    let(:user) { create :user, :admin, :confirmed, organization: organization }
    let(:area) { create :area, organization: organization }

    context "when an assembly associated to a given area exist" do
      let!(:assembly) { create(:assembly, organization: organization, area: area) }

      it "can not be deleted" do
        expect { subject.call }.to broadcast(:has_spaces)
        expect(area.reload.destroyed?).to be false
      end
    end
  end
end
