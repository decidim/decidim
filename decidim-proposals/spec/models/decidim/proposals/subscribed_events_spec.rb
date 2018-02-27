# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe Proposal do
      subject { proposal }

      let!(:organization) { create(:organization) }
      let!(:feature) { create(:feature, organization: organization, manifest_name: "proposals") }
      let!(:participatory_process) { create(:participatory_process, organization: organization) }
      let!(:author) { create(:user, :admin, organization: organization) }
      let!(:proposal) { create(:proposal, feature: feature, author: author) }
      let(:resource) do
        build(:dummy_resource)
      end

      context "on created event" do
        before do
          link_name= "included_proposals"
          event_name= "decidim.resourceable.#{link_name}.created"
          payload = {
            from_type: resource.class.name, from_id: resource.id,
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

        it "is valid" do
          proposal.reload
          expect(proposal.state).to eq("accepted")
        end
      end

    end
  end
end
