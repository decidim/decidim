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
      let(:user) { create(:user, organization: organization) }

      describe "results" do
        subject do
          described_class.new(
            search_text: search_text,
            state: state,
            type: type,
            author: author,
            scope_id: scope_id,
            current_user: user,
            organization: organization
          ).results
        end

        let(:search_text) { nil }
        let(:state) { nil }
        let(:type) { "all" }
        let(:author) { nil }
        let(:scope_id) { nil }

        describe "when the filter includes search_text" do
          let(:search_text) { "dog" }

          it "returns the initiatives containing the search in the title or the body" do
            create_list(:initiative, 3, organization: organization)
            create(:initiative, title: { "en": "A dog" }, organization: organization)
            create(:initiative, description: { "en": "There is a dog in the office" }, organization: organization)

            expect(subject.size).to eq(2)
          end
        end

        describe "when the filter includes state" do
          context "and filtering open initiatives" do
            let(:state) { "open" }

            it "returns only open initiatives" do
              open_initiatives = create_list(:initiative, 3, organization: organization)
              create_list(:initiative, 3, :acceptable, organization: organization)

              expect(subject.size).to eq(3)
              expect(subject).to match_array(open_initiatives)
            end
          end

          context "when filtering closed proposals" do
            let(:state) { "closed" }

            it "returns only closed initiatives" do
              create_list(:initiative, 3, organization: organization)
              closed_initiatives = create_list(:initiative, 3, :acceptable, organization: organization)

              expect(subject.size).to eq(3)
              expect(subject).to match_array(closed_initiatives)
            end
          end
        end

        context "when scope_id" do
          let!(:initiative) { create(:initiative, scoped_type: scoped_type1, organization: organization) }
          let!(:initiative2) { create(:initiative, scoped_type: scoped_type2, organization: organization) }

          context "when a scope id is being sent" do
            let(:scope_id) { scoped_type1.scope.id }

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

        context "when filter by author" do
          let!(:initiative) { create(:initiative, organization: organization) }
          let!(:initiative2) { create(:initiative, organization: organization, author: user) }

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

        context "when filter by type" do
          let!(:initiative) { create(:initiative, organization: organization) }
          let!(:initiative2) { create(:initiative, organization: organization) }
          let(:type) { initiative.type.id }

          it "filters by initiative type" do
            expect(subject).to match_array [initiative]
          end
        end
      end
    end
  end
end
