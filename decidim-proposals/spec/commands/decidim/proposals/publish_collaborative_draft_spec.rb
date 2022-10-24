# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe PublishCollaborativeDraft do
      let(:component) { create(:proposal_component) }
      let(:state) { :open }
      let!(:collaborative_draft) { create(:collaborative_draft, component:, state:) }
      let!(:attachment) { Decidim::Attachment.create(attachment_params) }
      let(:attachment_params) do
        {
          title: "My attachment",
          file: Decidim::Dev.test_file("city.jpeg", "image/jpeg"),
          attached_to: collaborative_draft
        }
      end
      let(:current_user) { collaborative_draft.creator_author }
      let(:command) { described_class.new(collaborative_draft, current_user) }

      describe "call" do
        context "when the user is not a coauthor" do
          let(:current_user) { create(:user, organization: component.organization) }

          it "broadcasts invalid" do
            expect(collaborative_draft.authored_by?(current_user)).to be(false)
            expect { command.call }.to broadcast(:invalid)
          end
        end

        context "when the resource is withdrawn" do
          let(:state) { :withdrawn }

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end
        end

        context "when the resource is published" do
          let(:state) { :published }

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end
        end

        context "when everything is ok" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "creates a new proposal" do
            expect { command.call }
              .to change(Decidim::Proposals::Proposal, :count)
              .by(1)
          end

          it "transfers the attributes correctly" do
            command.call
            proposal = Decidim::Proposals::Proposal.last

            expect(proposal.category).to eq(collaborative_draft.category)
            expect(proposal.scope).to eq(collaborative_draft.scope)
            expect(proposal.address).to eq(collaborative_draft.address)
            expect(proposal.attachments).to eq(collaborative_draft.attachments)
          end
        end
      end
    end
  end
end
