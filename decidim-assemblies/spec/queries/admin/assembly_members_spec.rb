# frozen_string_literal: true

require "spec_helper"

module Decidim::Assemblies::Admin
  describe AssemblyMembers do
    subject { described_class.for(Decidim::AssemblyMember.all, search, filter) }

    let(:organization) { create :organization }
    let(:search) { nil }
    let(:filter) { nil }

    describe "when the list is not filtered" do
      let!(:assembly_members) { create_list(:assembly_member, 3) }

      it "returns all the assembly members" do
        expect(subject).to eq assembly_members
      end
    end

    describe "when the list is filtered" do
      context "and receives a search param" do
        let(:assembly_members) do
          %w(Walter Fargo Phargo).map do |name|
            create(:assembly_member, full_name: name)
          end
        end

        context "with regular characters" do
          let(:search) { "Argo" }

          it "returns all matching assembly members" do
            expect(subject).to match_array([assembly_members[1], assembly_members[2]])
          end
        end

        context "with conflictive characters" do
          let(:search) { "Andy O'Connel" }

          it "returns all matching users" do
            expect(subject).to be_empty
          end
        end
      end

      context "and receives a filter param" do
        let!(:active_assembly_members) { create_list(:assembly_member, 2) }
        let!(:ceased_assembly_members) { create_list(:assembly_member, 4, :ceased) }

        context 'when the user filters by "Ceased"' do
          let(:filter) { "ceased" }

          it "returns all the ceased assembly members" do
            expect(subject).to eq(ceased_assembly_members)
          end
        end

        context 'when the user filters by "Not ceased"' do
          let(:filter) { "not_ceased" }

          it "returns all the active assembly members" do
            expect(subject).to eq(active_assembly_members)
          end
        end
      end

      context "and receives search and filter params at a time" do
        let(:ceased_assembly_members) do
          %w(Lorem Ipsum Dolor).map do |name|
            create(:assembly_member, :ceased, full_name: name)
          end
        end

        let(:search) { "lo" }
        let(:filter) { "ceased" }

        before do
          %w(Eloit Vivamus Doctum).map do |name|
            create(:user_group, name:)
          end
        end

        it 'returns the "Ceased" assembly members matching the query search' do
          expect(subject).to match_array([ceased_assembly_members[0], ceased_assembly_members[2]])
        end
      end
    end
  end
end
