# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    module Admin
      describe ManageableInitiatives do
        subject { described_class.for(user) }

        let!(:organization) { create(:organization) }

        let!(:author) { create(:user, organization:) }
        let!(:promoter) { create(:user, organization:) }
        let!(:admin) { create(:user, :admin, organization:) }

        let!(:author_initiatives) do
          create_list(:initiative, 3, organization:, author:)
        end
        let!(:promoter_initiatives) do
          create_list(:initiative, 3, organization:).each do |initiative|
            create(:initiatives_committee_member, initiative:, user: promoter)
          end
        end
        let!(:admin_initiatives) do
          create_list(:initiative, 3, organization:, author: admin)
        end

        context "when initiative authors" do
          let(:user) { author }

          it "includes user initiatives" do
            expect(subject).to include(*author_initiatives)
          end

          it "does not include admin initiatives" do
            expect(subject).not_to include(*admin_initiatives)
          end
        end

        context "when initiative promoters" do
          let(:user) { promoter }

          it "includes promoter initiatives" do
            expect(subject).to include(*promoter_initiatives)
          end

          it "does not include admin initiatives" do
            expect(subject).not_to include(*admin_initiatives)
          end
        end

        context "when administrator users" do
          let(:user) { admin }

          it "includes admin initiatives" do
            expect(subject).to include(*admin_initiatives)
          end

          it "includes user initiatives" do
            expect(subject).to include(*author_initiatives)
          end

          it "includes promoter initiatives" do
            expect(subject).to include(*promoter_initiatives)
          end
        end
      end
    end
  end
end
