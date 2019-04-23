# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe ProposalSerializer, processing_uploads_for: Decidim::AttachmentUploader do
      subject do
        described_class.new(proposal)
      end

      let!(:proposal) { create(:proposal, :accepted) }
      let!(:category) { create(:category, participatory_space: component.participatory_space) }
      let!(:scope) { create(:scope, organization: component.participatory_space.organization) }
      let(:participatory_process) { component.participatory_space }
      let(:component) { proposal.component }

      let!(:meetings_component) { create(:component, manifest_name: "meetings", participatory_space: participatory_process) }
      let(:meetings) { create_list(:meeting, 2, component: meetings_component) }

      let!(:proposals_component) { create(:proposal_component, :with_attachments_allowed, manifest_name: "proposals", participatory_space: participatory_process) }
      let(:other_proposals) { create_list(:proposal, 2, component: proposals_component) }

      let!(:emendation) { create(:proposal, component: component) }
      let!(:amendment) { create(:amendment, amendable: proposal, emendation: emendation) }

      let!(:attachment) { Decidim::Attachment.new(attachment_params) }
      let(:attachment_params) do
        {
          title: "My attachment",
          file: Decidim::Dev.test_file("city.jpeg", "image/jpeg"),
          content_type: "image/jpeg",
          attached_to: proposal
        }
      end

      before do
        attachment.save!
        proposal.update!(category: category)
        proposal.update!(scope: scope)
        proposal.link_resources(meetings, "proposals_from_meeting")
        proposal.link_resources(other_proposals, "copied_from_component")
      end

      describe "#serialize" do
        let(:serialized) { subject.serialize }

        it "serializes the id" do
          expect(serialized).to include(id: proposal.id)
        end

        it "serializes the category" do
          expect(serialized[:category]).to include(id: category.id)
          expect(serialized[:category]).to include(name: category.name)
        end

        it "serializes the scope" do
          expect(serialized[:scope]).to include(id: scope.id)
          expect(serialized[:scope]).to include(name: scope.name)
        end

        it "serializes the title" do
          expect(serialized).to include(title: proposal.title)
        end

        it "serializes the body" do
          expect(serialized).to include(body: proposal.body)
        end

        it "serializes the origin" do
          expect(serialized).to include(collaborative_draft_origin: proposal.collaborative_draft_origin)
        end

        it "serializes the amount of supports" do
          expect(serialized).to include(supports: proposal.proposal_votes_count)
        end

        it "serializes the amount of comments" do
          expect(serialized).to include(comments: proposal.comments.count)
        end

        it "serializes the amount of amendments" do
          expect(serialized).to include(amendments: proposal.amendments.count)
          expect(serialized[:amendments]).to eq(1)
        end

        it "serializes the date of creation" do
          expect(serialized).to include(published_at: proposal.published_at)
        end

        it "serializes the url" do
          expect(serialized[:url]).to include("http", proposal.id.to_s)
        end

        it "serializes the component" do
          expect(serialized[:component]).to include(id: proposal.component.id)
        end

        it "serializes the meetings" do
          expect(serialized[:meeting_urls].length).to eq(2)
          expect(serialized[:meeting_urls].first).to match(%r{http.*/meetings})
        end

        it "serializes the participatory space" do
          expect(serialized[:participatory_space]).to include(id: participatory_process.id)
          expect(serialized[:participatory_space][:url]).to include("http", participatory_process.slug)
        end

        it "serializes the state" do
          expect(serialized).to include(state: proposal.state)
        end

        it "serializes the reference" do
          expect(serialized).to include(reference: proposal.reference)
        end

        it "serializes attachments url" do
          expect(serialized[:attachments_url].first).to eq(proposal.organization.host + proposal.attachments.first.url)
          expect(serialized[:attachments_url].length).to eq(1)
        end

        it "serializes the amount of attachments" do
          expect(serialized).to include(attachments: proposal.attachments.count)
        end

        it "serializes the amount of endorsements" do
          expect(serialized).to include(endorsements: proposal.endorsements.count)
        end

        it "serializes related proposals" do
          expect(serialized[:related_proposals].length).to eq(2)
          expect(serialized[:related_proposals].first).to match(%r{http.*/proposals})
        end

        it "serializes the author profile url" do
          expect(serialized[:authors_url]).to all(match(%r{http.*/profiles}))
          expect(serialized[:authors_url].length).to eq(1)
        end

        context "when multiple authors" do
          let!(:users) { create_list(:user, 3, organization: proposals_component.organization) }
          let!(:proposal) { create(:proposal, :accepted) }

          before do
            users.each { |user| proposal.add_coauthor(user) }
          end

          it "serializes the authors url" do
            expect(serialized[:authors_url]).to all(match(%r{http.*/profiles}))
            expect(serialized[:authors_url].length).to eq(4)
          end

          context "when authors includes an official" do
            let!(:proposal) { create(:proposal, :accepted, :official) }

            it "serializes the authors" do
              expect(serialized[:authors_url].first).to eq("")
              expect(serialized[:authors_url][1..-1]).to all(match(%r{http.*/profiles}))
              expect(serialized[:authors_url].length).to eq(4)
            end
          end
        end
      end
    end
  end
end
