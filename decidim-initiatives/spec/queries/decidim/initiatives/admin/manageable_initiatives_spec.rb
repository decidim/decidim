# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    module Admin
      describe ManageableInitiatives do
        let!(:user) { create(:user, :confirmed, organization: organization) }
        let(:query) { nil }
        let!(:admin) do
          create(:user, :confirmed, :admin, organization: organization)
        end
        let!(:organization) { create(:organization) }
        let!(:user_initiatives) do
          create_list(:initiative, 3, organization: organization, author: user)
        end
        let!(:admin_initiatives) do
          create_list(:initiative, 3, organization: organization, author: admin)
        end

        context "when initiative authors" do
          subject { described_class.new(organization, user, query, nil) }

          it "includes only user initiatives" do
            expect(subject).not_to include(*admin_initiatives)
          end

          context "and filtering by query" do
            let(:user_initiative) { create(:initiative, organization: organization, author: user) }
            let(:query) { user_initiative.title["en"] }

            it "includes the initiative with the given title" do
              expect(subject).not_to include(*admin_initiatives)
              expect(subject).not_to include(*user_initiatives)
              expect(subject).to include(user_initiative)
            end
          end
        end

        context "when initiative promoters" do
          subject { described_class.new(organization, promoter, query, nil) }

          let(:promoter) { create(:user, organization: organization) }
          let(:promoter_initiatives) { create_list(:initiative, 3, organization: organization) }

          before do
            promoter_initiatives.each do |initiative|
              create(:initiatives_committee_member, initiative: initiative, user: promoter)
            end
          end

          it "includes only promoter initiatives" do
            expect(subject).to include(*promoter_initiatives)
            expect(subject).not_to include(*user_initiatives)
            expect(subject).not_to include(*admin_initiatives)
          end

          context "and filtering by query" do
            let(:initiative) { create(:initiative, organization: organization, author: user) }
            let(:query) { initiative.title["en"] }

            before do
              create(:initiatives_committee_member, initiative: initiative, user: promoter)
            end

            it "includes the initiative with the given title" do
              expect(subject).not_to include(*admin_initiatives)
              expect(subject).not_to include(*user_initiatives)
              expect(subject).not_to include(*promoter_initiatives)
              expect(subject).to include(initiative)
            end
          end
        end

        context "when administrator users" do
          subject { described_class.new(organization, admin, query, nil) }

          it "includes all initiatives" do
            expect(subject).to include(*user_initiatives)
            expect(subject).to include(*admin_initiatives)
          end

          context "and filtering by query" do
            let(:initiative) { create(:initiative, organization: organization, author: user) }
            let(:query) { "foo" }

            before do
              initiative.title["en"] = "Bar foo baz something"
              initiative.save
            end

            it "includes the initiative with the given title" do
              expect(subject).not_to include(*admin_initiatives)
              expect(subject).not_to include(*user_initiatives)
              expect(subject).to include(initiative)
            end
          end
        end
      end
    end
  end
end
