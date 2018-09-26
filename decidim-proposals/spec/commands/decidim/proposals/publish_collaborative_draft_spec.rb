# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe PublishCollaborativeDraft do
      let(:component) { create(:proposal_component) }
      let(:organization) { component.organization }
      let!(:current_user) { create(:user, organization: organization) }
      let(:follower) { create(:user, organization: organization) }
      let(:other_author) { create(:user, organization: organization) }
      let(:state) { :open }
      let(:collaborative_draft) { create(:collaborative_draft, component: component, state: state, users: [current_user, other_author]) }
      let!(:follow) { create :follow, followable: current_user, user: follower }

      describe "call" do
        it "broadcasts ok" do
          expect { described_class.call(collaborative_draft, current_user) }.to broadcast(:ok)
        end

        it "broadcasts invalid when the user is not a coauthor" do
          expect { described_class.call(collaborative_draft, follower) }.to broadcast(:invalid)
        end

        context "when the resource is withdrawn" do
          let(:state) { :withdrawn }

          it "broadcasts invalid" do
            expect { described_class.call(collaborative_draft, follower) }.to broadcast(:invalid)
          end
        end

        context "when the resource is published" do
          let(:state) { :published }

          it "broadcasts invalid" do
            expect { described_class.call(collaborative_draft, follower) }.to broadcast(:invalid)
          end
        end
      end
    end
  end
end
