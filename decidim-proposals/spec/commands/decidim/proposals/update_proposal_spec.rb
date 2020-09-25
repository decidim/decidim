# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe UpdateProposal do
      let(:form_klass) { ProposalForm }

      let(:component) { create(:proposal_component, :with_extra_hashtags, suggested_hashtags: suggested_hashtags.join(" ")) }
      let(:organization) { component.organization }
      let(:form) do
        form_klass.from_params(
          form_params
        ).with_context(
          current_organization: organization,
          current_participatory_space: component.participatory_space,
          current_component: component
        )
      end

      let!(:proposal) { create :proposal, component: component, users: [author] }
      let(:author) { create(:user, organization: organization) }

      let(:user_group) do
        create(:user_group, :verified, organization: organization, users: [author])
      end

      let(:has_address) { false }
      let(:address) { nil }
      let(:latitude) { 40.1234 }
      let(:longitude) { 2.1234 }
      let(:suggested_hashtags) { [] }
      let(:attachment_params) { nil }
      let(:uploaded_photos) { [] }
      let(:current_photos) { [] }
      let(:current_files) { [] }
      let(:uploaded_files) { [] }
      let(:errors) { double.as_null_object }

      describe "call" do
        let(:form_params) do
          {
            title: "A reasonable proposal title",
            body: "A reasonable proposal body",
            address: address,
            has_address: has_address,
            user_group_id: user_group.try(:id),
            suggested_hashtags: suggested_hashtags,
            attachment: attachment_params,
            photos: current_photos,
            add_photos: uploaded_photos,
            files: current_files,
            add_files: uploaded_files,
            errors: errors
          }
        end

        let(:command) do
          described_class.new(form, author, proposal)
        end

        describe "when the form is not valid" do
          before do
            expect(form).to receive(:invalid?).and_return(true)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't update the proposal" do
            expect do
              command.call
            end.not_to change(proposal, :title)
          end
        end

        describe "when the proposal is not editable by the user" do
          before do
            expect(proposal).to receive(:editable_by?).and_return(false)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't update the proposal" do
            expect do
              command.call
            end.not_to change(proposal, :title)
          end
        end

        context "when the author changinng the author to one that has reached the proposal limit" do
          let!(:other_proposal) { create :proposal, component: component, users: [author], user_groups: [user_group] }
          let(:component) { create(:proposal_component, :with_proposal_limit) }

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end
        end

        describe "when the form is valid" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "updates the proposal" do
            expect do
              command.call
            end.to change(proposal, :title)
          end

          context "with an author" do
            let(:user_group) { nil }

            it "sets the author" do
              command.call
              proposal = Decidim::Proposals::Proposal.last

              expect(proposal).to be_authored_by(author)
              expect(proposal.identities.include?(user_group)).to be false
            end
          end

          context "with a user group" do
            it "sets the user group" do
              command.call
              proposal = Decidim::Proposals::Proposal.last

              expect(proposal).to be_authored_by(author)
              expect(proposal.identities).to include(user_group)
            end
          end

          context "with extra hashtags" do
            let(:suggested_hashtags) { %w(Hashtag1 Hashtag2) }

            it "saves the extra hashtags" do
              command.call
              proposal = Decidim::Proposals::Proposal.last
              expect(proposal.body).to include("_Hashtag1")
              expect(proposal.body).to include("_Hashtag2")
            end
          end

          context "when geocoding is enabled" do
            let(:component) { create(:proposal_component, :with_geocoding_enabled) }

            context "when the has address checkbox is checked" do
              let(:has_address) { true }

              context "when the address is present" do
                let(:address) { "Carrer Pare Llaurador 113, baixos, 08224 Terrassa" }

                before do
                  stub_geocoding(address, [latitude, longitude])
                end

                it "sets the latitude and longitude" do
                  command.call
                  proposal = Decidim::Proposals::Proposal.last

                  expect(proposal.latitude).to eq(latitude)
                  expect(proposal.longitude).to eq(longitude)
                end
              end
            end
          end

          context "when attachments are allowed", processing_uploads_for: Decidim::AttachmentUploader do
            let(:component) { create(:proposal_component, :with_attachments_allowed) }
            let(:uploaded_files) do
              [
                Decidim::Dev.test_file("city.jpeg", "image/jpeg"),
                Decidim::Dev.test_file("Exampledocument.pdf", "application/pdf")
              ]
            end

            it "creates multiple atachments for the proposal" do
              expect { command.call }.to change(Decidim::Attachment, :count).by(2)
              last_proposal = Decidim::Proposals::Proposal.last
              last_attachment = Decidim::Attachment.last
              expect(last_attachment.attached_to).to eq(last_proposal)
            end
          end

          context "when attachments are allowed and file is invalid", processing_uploads_for: Decidim::AttachmentUploader do
            let(:component) { create(:proposal_component, :with_attachments_allowed) }
            let(:uploaded_files) do
              [
                Decidim::Dev.test_file("city.jpeg", ""),
                Decidim::Dev.test_file("Exampledocument.pdf", "application/pdf")
              ]
            end

            it "does not create atachments for the proposal" do
              expect { command.call }.to change(Decidim::Attachment, :count).by(0)
            end
          end

          context "when gallery are allowed", processing_uploads_for: Decidim::AttachmentUploader do
            let(:component) { create(:proposal_component, :with_attachments_allowed) }
            let(:uploaded_photos) { [Decidim::Dev.test_file("city.jpeg", "image/jpeg")] }

            it "creates an image attachment for the proposal" do
              expect { command.call }.to change(Decidim::Attachment, :count).by(1)
              last_proposal = Decidim::Proposals::Proposal.last
              last_attachment = Decidim::Attachment.last
              expect(last_attachment.attached_to).to eq(last_proposal)
            end
          end
        end
      end
    end
  end
end
