# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    module ParticipatorySpace
      describe DestroyMembersFollowsJob do
        let(:organization) { create(:organization) }
        let!(:user) { create(:user, :admin, :confirmed, organization:) }
        let!(:normal_user) { create(:user, organization:) }
        let!(:follow) { create(:follow, followable: participatory_space, user: normal_user) }
        let(:component) { create(:dummy_component, participatory_space:) }
        let(:resource) { create(:dummy_resource, component:, author: user) }
        let!(:followed_resource) { create(:follow, followable: resource, user: normal_user) }

        context "when assembly is restricted" do
          let(:participatory_space) { create(:assembly, :restricted, :published, organization: user.organization) }

          it "deletes follows of non members" do
            # we have 2 follows, one for assembly, and one for a "child" resource
            expect { described_class.perform_now(normal_user.id, participatory_space) }.to change(Decidim::Follow, :count).by(-2)
          end
        end

        context "when assembly is transparent" do
          let(:participatory_space) { create(:assembly, :transparent, :published, organization: user.organization) }

          it "preserves follows of non members" do
            # we have 2 follows, one for assembly, and one for a "child" resource
            expect { described_class.perform_now(normal_user.id, participatory_space) }.not_to change(Decidim::Follow, :count)
          end
        end

        context "when assembly is open" do
          let(:participatory_space) { create(:assembly, :open, :published, organization: user.organization) }

          it "preserves follows of non members" do
            # we have 2 follows, one for assembly, and one for a "child" resource
            expect { described_class.perform_now(normal_user.id, participatory_space) }.not_to change(Decidim::Follow, :count)
          end
        end

        context "when process is restricted" do
          let(:participatory_space) { create(:participatory_process, :restricted, :published, organization: user.organization) }

          it "deletes follows of non members" do
            # we have 2 follows, one for process, and one for a "child" resource
            expect { described_class.perform_now(normal_user.id, participatory_space) }.to change(Decidim::Follow, :count).by(-2)
          end
        end

        context "when process is open" do
          let(:participatory_space) { create(:participatory_process, :open, :published, organization: user.organization) }

          it "preserves follows of non members" do
            expect { described_class.perform_now(normal_user.id, participatory_space) }.not_to change(Decidim::Follow, :count)
          end
        end
      end
    end
  end
end
