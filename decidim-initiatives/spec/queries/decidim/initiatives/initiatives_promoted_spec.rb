# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    describe InitiativesPromoted do
      let!(:user) { create(:user, :confirmed, organization:) }
      let!(:admin) { create(:user, :confirmed, :admin, organization:) }
      let!(:organization) { create(:organization) }
      let!(:user_initiatives) { create_list(:initiative, 3, organization:, author: user) }
      let!(:admin_initiatives) { create_list(:initiative, 3, organization:, author: admin) }

      context "when initiative promoters" do
        subject { described_class.new(promoter) }

        let(:promoter) { create(:user, organization:) }
        let(:promoter_initiatives) { create_list(:initiative, 3, organization:) }

        before do
          promoter_initiatives.each do |initiative|
            create(:initiatives_committee_member, initiative:, user: promoter)
          end
        end

        it "includes only promoter initiatives" do
          expect(subject).to include(*promoter_initiatives)
          expect(subject).not_to include(*user_initiatives)
          expect(subject).not_to include(*admin_initiatives)
        end
      end
    end
  end
end
