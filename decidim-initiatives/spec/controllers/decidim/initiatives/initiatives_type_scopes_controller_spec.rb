# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    describe InitiativesTypeScopesController do
      routes { Decidim::Initiatives::Engine.routes }

      let(:organization) { create(:organization) }
      let(:initiative_type) do
        type = create(:initiatives_type, organization:)

        3.times do
          InitiativesTypeScope.create(
            type:,
            scope: create(:scope, organization:),
            supports_required: 1000
          )
        end

        type
      end

      let(:other_initiative_type) do
        type = create(:initiatives_type, organization:)

        3.times do
          InitiativesTypeScope.create(
            type:,
            scope: create(:scope, organization:),
            supports_required: 1000
          )
        end

        type
      end

      describe "GET search" do
        before do
          request.env["decidim.current_organization"] = organization
        end

        it "Returns only scoped types for the given type" do
          expect(other_initiative_type.scopes).not_to be_empty

          get :search, params: { type_id: initiative_type.id, locale: I18n.locale }

          expect(subject.helpers.scoped_types).to include(*initiative_type.scopes)
          expect(subject.helpers.scoped_types).not_to include(*other_initiative_type.scopes)
        end
      end
    end
  end
end
