# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe EndorsableHelper do
    describe "endorsements enabled" do
      subject { helper.endorsements_enabled? }

      before do
        allow(helper).to receive(:current_settings).and_return(double(endorsements_enabled:))
      end

      context "when endorsements are enabled" do
        let(:endorsements_enabled) { true }

        it { is_expected.to be true }
      end

      context "when endorsements are NOT enabled" do
        let(:endorsements_enabled) { false }

        it { is_expected.to be false }
      end
    end

    describe "endorsements blocked" do
      subject { helper.endorsements_blocked? }

      before do
        allow(helper).to receive(:current_settings).and_return(double(endorsements_blocked:))
      end

      context "when endorsements are blocked" do
        let(:endorsements_blocked) { true }

        it { is_expected.to be true }
      end

      context "when endorsements are NOT blocked" do
        let(:endorsements_blocked) { false }

        it { is_expected.to be false }
      end
    end

    describe "render_endorsement_identity" do
      subject { helper.render_endorsement_identity(resource, user, user_group) }

      let(:organization) { create(:organization) }
      let(:component) { create(:component, :published, organization:) }
      let(:resource) { create(:dummy_resource, component:) }
      let(:user) { create(:user, :confirmed, organization:) }
      let(:user_group) { nil }

      before do
        allow(helper).to receive(:endorsements_path).and_return(Decidim::Core::Engine.routes.url_helpers.endorsements_path(id: resource))
        allow(helper).to receive(:endorsement_path).and_return(Decidim::Core::Engine.routes.url_helpers.endorsement_path(id: resource))
        allow(controller).to receive(:current_user).and_return(user)
      end

      context "when it's a user" do
        context "and they haven't endorsed yet" do
          it { is_expected.not_to include("selected") }
        end

        context "and they have already endorsed" do
          let!(:endorsement) { create(:endorsement, resource:, author: user) }

          it { is_expected.to include("selected") }
        end
      end

      context "when it's a user group" do
        let(:another_user) { create(:user, :confirmed, organization:) }
        let!(:user_group) { create(:user_group, verified_at: Time.current, organization:) }
        let!(:membership) { create(:user_group_membership, user_group:, user:, role: "admin") }
        let!(:another_membership) { create(:user_group_membership, user_group:, user: another_user, role: "admin") }

        context "and they haven't endorsed yet" do
          it { is_expected.not_to include("selected") }
        end

        context "and they have already endorsed" do
          let!(:endorsement) { create(:endorsement, resource:, author: user, user_group:) }

          it { is_expected.to include("selected") }
        end

        context "and another admin of the group have already endorsed" do
          let!(:endorsement) { create(:endorsement, resource:, author: another_user, user_group:) }

          it { is_expected.to include("selected") }
        end
      end
    end
  end
end
