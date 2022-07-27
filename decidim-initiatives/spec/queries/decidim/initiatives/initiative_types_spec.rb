# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    describe InitiativeTypes do
      subject { described_class.new(organization) }

      let!(:organization) { create(:organization) }
      let!(:initiative_types) { create_list(:initiatives_type, 3, organization:) }

      let!(:other_organization) { create(:organization) }
      let!(:other_initiative_types) { create_list(:initiatives_type, 3, organization: other_organization) }

      it "Returns only initiative types for the given organization" do
        expect(subject).to include(*initiative_types)
        expect(subject).not_to include(*other_initiative_types)
      end
    end
  end
end
