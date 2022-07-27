# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    describe CreateInitiativeHelper do
      let(:online) { %w(Online online) }
      let(:offline) { ["In-person", "offline"] }
      let(:mixed) { %w(Mixed any) }
      let(:all) { [online, offline, mixed] }

      let(:organization) { create(:organization) }
      let(:initiative_type) { create(:initiatives_type, signature_type:, organization:) }
      let(:scope) { create(:initiatives_type_scope, type: initiative_type) }
      let(:initiative_state) { "created" }
      let(:initiative) { create(:initiative, organization:, scoped_type: scope, signature_type:, state: initiative_state) }

      let(:form_klass) { ::Decidim::Initiatives::Admin::InitiativeForm }
      let(:form) do
        form_klass.from_params(
          form_params
        ).with_context(
          current_organization: organization,
          initiative:
        )
      end
      let(:form_params) do
        {
          type_id: initiative_type.id,
          decidim_scope_id: scope.id,
          state: initiative_state
        }
      end
      let(:options) do
        helper.signature_type_options(form)
      end

      context "when any signature enabled" do
        let(:signature_type) { "any" }

        it "contains online and offline signature type options" do
          expect(options).to match_array(all)
        end
      end

      context "when online signature disabled" do
        let(:signature_type) { "offline" }

        it "contains offline signature type options" do
          expect(options).not_to include(online)
          expect(options).not_to include(mixed)
          expect(options).to include(offline)
        end
      end

      context "when online signature enabled" do
        let(:signature_type) { "online" }

        it "contains all signature type options" do
          expect(options).to include(online)
          expect(options).not_to include(mixed)
          expect(options).not_to include(offline)
        end
      end
    end
  end
end
