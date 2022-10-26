# frozen_string_literal: true

require "spec_helper"

module Decidim::Core
  describe Engine do
    describe "initializers" do
      let(:initializer_name) { nil }
      let(:initializer) { described_class.initializers.find { |i| i.name == initializer_name } }

      context "when running the 'SSL and HSTS' initializer" do
        let(:initializer_name) { "SSL and HSTS" }

        before do
          allow(Decidim.config).to receive(:force_ssl).and_return(decidim_force_ssl)
          initializer.run
        end

        after do
          Rails.application.config.force_ssl = false
        end

        context "when Decidim.config.force_ssl is true" do
          let(:decidim_force_ssl) { true }

          it "configures the force_ssl according to the Decidim setting" do
            expect(Rails.application.config.force_ssl).to be(true)
          end
        end

        context "when Decidim.config.force_ssl is false" do
          let(:decidim_force_ssl) { false }

          it "configures the force_ssl according to the Decidim setting" do
            expect(Rails.application.config.force_ssl).to be(false)
          end
        end
      end

      context "when running the 'Expire sessions' initializer" do
        let(:initializer_name) { "Expire sessions" }
        let(:decidim_force_ssl) { false }
        let(:decidim_expire_session_after) { 30.minutes }

        before do
          allow(Decidim.config).to receive(:force_ssl).and_return(decidim_force_ssl)
          allow(Decidim.config).to receive(:expire_session_after).and_return(decidim_expire_session_after)
          initializer.run
        end

        after do
          Rails.application.config.force_ssl = false
          Rails.application.config.expire_session_after = 30.minutes
        end

        context "when Decidim.config.force_ssl is true" do
          let(:decidim_force_ssl) { true }

          it "configures the session cookie store with the secure flag" do
            expect(Rails.application.config.session_options).to eq(
              secure: true,
              expire_after: 30.minutes
            )
          end
        end

        context "when Decidim.config.force_ssl is false" do
          let(:decidim_force_ssl) { false }

          it "configures the session cookie store without the secure flag" do
            expect(Rails.application.config.session_options).to eq(
              secure: false,
              expire_after: 30.minutes
            )
          end
        end

        context "when expire session after is set to a custom amount" do
          let(:decidim_expire_session_after) { 1.hour }

          it "configures the session cookie store with the correct expire after value" do
            expect(Rails.application.config.session_options).to eq(
              secure: false,
              expire_after: 1.hour
            )
          end
        end
      end
    end

    describe "decidim.authorization_transfer" do
      include_context "authorization transfer"

      let(:component) { create(:component, organization:) }
      let(:coauthorables) { build_list(:dummy_resource, 5, component:) }
      let(:endorsables) { build_list(:dummy_resource, 10, component:) }
      let(:amendable) { build(:dummy_resource, component:) }
      let(:emendation) { build(:dummy_resource, component:) }
      let(:original_records) do
        {
          amendments: create_list(:amendment, 3, amendable:, emendation:, amender: original_user),
          coauthorships: coauthorables.map { |coauthorable| create(:coauthorship, coauthorable:, author: original_user) },
          endorsements: endorsables.map { |endorsable| create(:endorsement, resource: endorsable, author: original_user) }
        }
      end
      let(:transferred_amendments) { Decidim::Amendment.where(amender: target_user).order(:id) }
      let(:transferred_coauthorships) { Decidim::Coauthorship.where(author: target_user).order(:id) }
      let(:transferred_endorsements) { Decidim::Endorsement.where(author: target_user).order(:id) }

      it "handles authorization transfer correctly" do
        expect(transferred_amendments.count).to eq(3)
        expect(transferred_coauthorships.count).to eq(5)
        expect(transferred_endorsements.count).to eq(10)
        expect(transfer.records.count).to eq(18)
        expect(transferred_resources).to eq(transferred_amendments + transferred_coauthorships + transferred_endorsements)
      end
    end

    it "loads engine mailer previews" do
      expect(ActionMailer::Preview.all).to include(Decidim::DeviseMailerPreview)
    end
  end
end
