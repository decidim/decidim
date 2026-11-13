# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    describe InitiativeTypesWithInitiatives do
      subject { described_class.new(organization) }

      let!(:organization) { create(:organization) }
      let!(:initiative_type_without_initiatives) { create(:initiatives_type, organization:) }
      let!(:initiative_type_with_initiatives) { create(:initiatives_type, organization:) }

      let!(:other_organization) { create(:organization) }
      let!(:other_initiative_type_with_initiatives) { create(:initiatives_type, organization: other_organization) }

      before do
        create(:initiatives_type_scope, type: initiative_type_without_initiatives)
        create(:initiative, organization:, scoped_type: create(:initiatives_type_scope, type: initiative_type_with_initiatives))
        create(
          :initiative,
          organization: other_organization,
          scoped_type: create(:initiatives_type_scope, type: other_initiative_type_with_initiatives)
        )
      end

      it "returns only the ids of the initiative types of the given organization with initiatives" do
        expect(subject).to contain_exactly(initiative_type_with_initiatives.id)
      end

      it "does not include initiative types with scopes without initiatives" do
        expect(subject).not_to include(initiative_type_without_initiatives.id)
      end
    end
  end
end
