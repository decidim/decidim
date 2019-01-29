# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    describe CreateInitiativeHelper do
      let(:online) { %w(OnLine online) }
      let(:offline) { ["Face to face", "offline"] }
      let(:mixed) { %w(Mixed any) }
      let(:all) { [online, offline, mixed] }

      let(:organization) { create(:organization) }
      let(:signature_type) { "offline" }
      let(:initiative_state) { "created" }
      let(:signature_setting) { :online_signature_enabled }

      let(:initiative_type) { create(:initiatives_type, signature_setting, organization: organization) }
      let(:scope) { create(:initiatives_type_scope, type: initiative_type) }
      let(:initiative) { create(:initiative, organization: organization, scoped_type: scope, signature_type: signature_type, state: initiative_state) }

      let(:form_klass) { ::Decidim::Initiatives::Admin::InitiativeForm }
      let(:form) do
        form_klass.from_params(
          form_params
        ).with_context(
          current_organization: organization,
          current_component: nil,
          initiative: initiative
        )
      end
      let(:form_params) do
        {
          title: { en: "A reasonable initiative title" },
          signature_start_date: Date.current,
          signature_end_date: Date.current + 1.day,
          signature_type: signature_type,
          type_id: initiative_type.id,
          decidim_scope_id: scope.id,
          state: initiative.state
        }
      end

      context "when online signature enabled" do
        let(:signature_type_options) { helper.signature_type_options(form) }

        it "contains online and offline signature type options" do
          expect(signature_type_options).to match_array(all)
        end
      end

      context "when online signature disabled" do
        let(:signature_setting) { :online_signature_disabled }
        let(:signature_type_options) { helper.signature_type_options(form) }

        it "contains offline signature type options" do
          expect(signature_type_options).not_to include(online)
          expect(signature_type_options).not_to include(mixed)
          expect(signature_type_options).to include(offline)
        end
      end

      context "when signature setting changed" do
        let(:signature_type) { "online" }
        let(:initiative_state) { "published" }
        let(:signature_type_options) { helper.signature_type_options(form) }

        before { initiative_type.update!(online_signature_enabled: false) }

        it "contains all signature type options" do
          expect(signature_type_options).to match_array(all)
        end
      end

      context "when signature setting changed" do
        let(:signature_type) { "online" }
        let(:initiative_state) { "published" }
        let(:signature_type_options) { helper.signature_type_options(form) }

        before { initiative_type.update!(online_signature_enabled: false) }

        it "contains all signature type options" do
          expect(signature_type_options).to match_array(all)
        end
      end
    end
  end
end
