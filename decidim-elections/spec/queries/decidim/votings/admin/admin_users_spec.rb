# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Votings
    module Admin
      describe AdminUsers do
        subject { described_class.new(voting) }

        let(:organization) { create :organization }
        let!(:voting) { create :voting, organization: }
        let!(:admins) { create_list(:user, 3, :admin, :confirmed, organization:) }
        let!(:normal_user) { create(:user, :confirmed, organization:) }
        let!(:other_organization_user) { create(:user, :confirmed) }

        it "returns the organization admins" do
          expect(subject.query).to match_array(admins)
        end
      end
    end
  end
end
