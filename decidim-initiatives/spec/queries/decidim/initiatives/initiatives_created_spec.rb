# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    describe InitiativesCreated do
      let!(:user) { create(:user, :confirmed, organization:) }
      let!(:admin) { create(:user, :confirmed, :admin, organization:) }
      let!(:organization) { create(:organization) }
      let!(:user_initiatives) { create_list(:initiative, 3, organization:, author: user) }
      let!(:admin_initiatives) { create_list(:initiative, 3, organization:, author: admin) }

      context "when initiative authors" do
        subject { described_class.new(user) }

        it "includes only user initiatives" do
          expect(subject).to include(*user_initiatives)
          expect(subject).not_to include(*admin_initiatives)
        end
      end
    end
  end
end
