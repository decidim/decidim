# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    describe InitiativeSearch do
      let(:organization) { create :organization }
      let(:type1) { create :initiatives_type, organization: organization }
      let(:type2) { create :initiatives_type, organization: organization }
      let(:scoped_type1) { create :initiatives_type_scope, type: type1 }
      let(:scoped_type2) { create :initiatives_type_scope, type: type2 }
      let(:user1) { create(:user, organization: organization, name: "John McDog") }
      let(:user2) { create(:user, organization: organization, nickname: "dogtrainer") }
      let(:group1) { create(:user_group, organization: organization, name: "The Dog House") }
      let(:group2) { create(:user_group, organization: organization, nickname: "thedogkeeper") }

      describe "results" do
        subject do
          described_class.new(
            search_text: search_text,
            state: state,
            type_id: type_id,
            author: author,
            scope_id: scope_id,
            current_user: user1,
            organization: organization
          ).results
        end

        let(:search_text) { nil }
        let(:state) { nil }
        let(:type_id) { ["all"] }
        let(:author) { nil }
        let(:scope_id) { nil }

        context "when the filter includes search_text" do
          let(:search_text) { "dog" }

          before do
            create_list(:initiative, 3, organization: organization)
            create(:initiative, title: { en: "A dog" }, organization: organization)
            create(:initiative, description: { en: "There is a dog in the office" }, organization: organization)
            create(:initiative, organization: organization, author: user1)
            create(:initiative, organization: organization, author: user2)
            create(:initiative, organization: organization, author: group1)
            create(:initiative, organization: organization, author: group2)
          end

          it "returns the initiatives containing the search in the title or the body or the author name or nickname" do
            expect(subject.size).to eq(6)
          end

          context "when the search_text is an initiative id" do
            let(:initiative) { create(:initiative, organization: organization) }
            let(:search_text) { initiative.id.to_s }

            it "returns the initiative with the searched id" do
              expect(subject).to contain_exactly(initiative)
            end
          end
        end

        context "when the filter includes state" do
          context "and filtering open initiatives" do
            let(:state) { ["open"] }

            it "returns only open initiatives" do
              open_initiatives = create_list(:initiative, 3, organization: organization)
              create_list(:initiative, 3, :acceptable, organization: organization)

              expect(subject.size).to eq(3)
              expect(subject).to match_array(open_initiatives)
            end
          end

          context "and filtering closed initiatives" do
            let(:state) { ["closed"] }

            it "returns only closed initiatives" do
              create_list(:initiative, 3, organization: organization)
              closed_initiatives = create_list(:initiative, 3, :acceptable, organization: organization)

              expect(subject.size).to eq(3)
              expect(subject).to match_array(closed_initiatives)
            end
          end

          context "and filtering accepted initiatives" do
            let(:state) { ["accepted"] }

            it "returns only accepted initiatives" do
              create_list(:initiative, 3, organization: organization)
              accepted_initiatives = create_list(:initiative, 3, :accepted, organization: organization)

              expect(subject.size).to eq(3)
              expect(subject).to match_array(accepted_initiatives)
            end
          end

          context "and filtering rejected initiatives" do
            let(:state) { ["rejected"] }

            it "returns only rejected initiatives" do
              create_list(:initiative, 3, organization: organization)
              rejected_initiatives = create_list(:initiative, 3, :rejected, organization: organization)

              expect(subject.size).to eq(3)
              expect(subject).to match_array(rejected_initiatives)
            end
          end

          context "and filtering answered initiatives" do
            let(:state) { ["answered"] }

            it "returns only answered initiatives" do
              create_list(:initiative, 3, organization: organization)
              answered_initiatives = create_list(:initiative, 3, :rejected, organization: organization, answered_at: Time.current)

              expect(subject.size).to eq(3)
              expect(subject).to match_array(answered_initiatives)
            end
          end
        end

        context "when the filter includes scope_id" do
          let!(:initiative) { create(:initiative, scoped_type: scoped_type1, organization: organization) }
          let!(:initiative2) { create(:initiative, scoped_type: scoped_type2, organization: organization) }

          context "when a scope id is being sent" do
            let(:scope_id) { [scoped_type1.scope.id] }

            it "filters initiatives by scope" do
              expect(subject).to match_array [initiative]
            end
          end

          context "when multiple ids are sent" do
            let(:scope_id) { [scoped_type2.scope.id, scoped_type1.scope.id] }

            it "filters initiatives by scope" do
              expect(subject).to match_array [initiative, initiative2]
            end
          end
        end

        context "when the filter includes author" do
          let!(:initiative) { create(:initiative, organization: organization) }
          let!(:initiative2) { create(:initiative, organization: organization, author: user1) }

          context "and any author" do
            it "contains all initiatives" do
              expect(subject).to match_array [initiative, initiative2]
            end
          end

          context "and my initiatives" do
            let(:author) { "myself" }

            it "contains only initiatives of the author" do
              expect(subject).to match_array [initiative2]
            end
          end
        end

        context "when the filter includes type_id" do
          let!(:initiative) { create(:initiative, organization: organization) }
          let!(:initiative2) { create(:initiative, organization: organization) }
          let(:type_id) { [initiative.type.id] }

          it "filters by initiative type" do
            expect(subject).to match_array [initiative]
          end

          context "with multiple types" do
            let(:type_id) { [initiative.type.id, initiative2.type.id] }

            it "filters by initiative type" do
              expect(subject).to match_array [initiative, initiative2]
            end
          end
        end
      end
    end
  end
end
