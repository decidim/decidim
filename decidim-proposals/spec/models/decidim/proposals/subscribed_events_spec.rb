# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe Proposal do
      subject { proposal }

      let!(:organization) { create(:organization) }
      let!(:component) { create(:component, organization:, manifest_name: "proposals") }
      let!(:participatory_process) { create(:participatory_process, organization:) }
      let!(:author) { create(:user, :admin, organization:) }
      let!(:proposal) { create(:proposal, component:, users: [author]) }
      let(:resource) do
        build(:dummy_resource)
      end

      context "when event is created" do
        before do
          link_name = "included_proposals"
          event_name = "decidim.resourceable.#{link_name}.created"
          payload = {
            from_type: "Decidim::Accountability::Result", from_id: resource.id,
            to_type: proposal.class.name, to_id: proposal.id
          }
          ActiveSupport::Notifications.instrument event_name, this: payload do
            Decidim::ResourceLink.create!(
              from: resource,
              to: resource,
              name: link_name,
              data: {}
            )
          end
        end

        it "is accepted" do
          proposal.reload
          expect(proposal.state).to eq("accepted")
        end
      end
    end
  end
end
