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

      let!(:proposal) { create(:proposal, component:, users: [author]) }
      let(:author) { create(:user, organization:) }

      let(:has_address) { false }
      let(:address) { nil }
      let(:latitude) { 40.1234 }
      let(:longitude) { 2.1234 }
      let(:suggested_hashtags) { [] }
      let(:attachment_params) { nil }
      let(:current_files) { [] }
      let(:uploaded_files) { [] }
      let(:errors) { double.as_null_object }

      describe "call" do
        let(:title) { "A reasonable proposal title" }
        let(:body) { "A reasonable proposal body" }
        let(:form_params) do
          {
            title:,
            body:,
            address:,
            has_address:,
            suggested_hashtags:,
            attachment: attachment_params,
            documents: current_files,
            add_documents: uploaded_files,
            errors:
          }
        end

        let(:command) do
          described_class.new(form, author, proposal)
        end

        describe "when the form is not valid" do
          before do
            allow(form).to receive(:invalid?).and_return(true)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "does not update the proposal" do
            expect do
              command.call
            end.not_to change(proposal, :title)
          end
        end

        describe "when the proposal is not editable by the user" do
          before do
            allow(proposal).to receive(:editable_by?).and_return(false)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "does not update the proposal" do
            expect do
              command.call
            end.not_to change(proposal, :title)
          end
        end

        context "when the author changing the author to one that has reached the proposal limit" do
          let!(:other_proposal) { create(:proposal, component:, users: [author]) }
          let(:component) { create(:proposal_component, :with_proposal_limit) }

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end
        end

        describe "when the form is valid" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it_behaves_like "fires an ActiveSupport::Notification event", "decidim.proposals.update_proposal:before"
          it_behaves_like "fires an ActiveSupport::Notification event", "decidim.proposals.update_proposal:after"

          it "updates the proposal" do
            command.call
            proposal.reload
            expect(proposal.title).to be_a(Hash)
            expect(proposal.title["en"]).to eq title
            expect(proposal.body).to be_a(Hash)
            expect(proposal.body["en"]).to match(/^#{body}/)
          end

          context "with an author" do
            it "sets the author" do
              command.call
              proposal = Decidim::Proposals::Proposal.last

              expect(proposal).to be_authored_by(author)
            end
          end

          context "with extra hashtags" do
            let(:suggested_hashtags) { %w(Hashtag1 Hashtag2) }

            it "saves the extra hashtags" do
              command.call
              proposal = Decidim::Proposals::Proposal.last
              expect(proposal.body["en"]).to include("_Hashtag1")
              expect(proposal.body["en"]).to include("_Hashtag2")
            end
          end

          context "when geocoding is enabled" do
            let(:component) { create(:proposal_component, :with_geocoding_enabled) }

            context "when the has address checkbox is checked" do
              let(:has_address) { true }

              context "when the address is present" do
                let(:address) { "Some address" }

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

          context "when attachments are allowed" do
            let(:component) { create(:proposal_component, :with_attachments_allowed) }
            let(:uploaded_files) do
              [
                file: upload_test_file(Decidim::Dev.asset("Exampledocument.pdf"), content_type: "application/pdf")
              ]
            end

            it "creates multiple attachments for the proposal" do
              expect { command.call }.to change(Decidim::Attachment, :count).by(1)
              last_attachment = Decidim::Attachment.last
              expect(last_attachment.attached_to).to eq(proposal)
            end

            context "with previous attachments" do
              let!(:file) { create(:attachment, :with_pdf, attached_to: proposal) }
              let(:current_files) { [file] }

              it "does not remove older attachments" do
                expect { command.call }.to change(Decidim::Attachment, :count).from(1).to(2)
              end
            end
          end

          context "when attachments are allowed and file is invalid" do
            let(:component) { create(:proposal_component, :with_attachments_allowed) }
            let(:uploaded_files) do
              [
                { file: upload_test_file(Decidim::Dev.asset("Exampledocument.pdf"), content_type: "application/pdf") },
                { file: upload_test_file(Decidim::Dev.asset("verify_user_groups.csv"), content_type: "text/csv") }
              ]
            end

            it "does not create attachments for the proposal" do
              expect { command.call }.not_to change(Decidim::Attachment, :count)
            end

            it "broadcasts invalid" do
              expect { command.call }.to broadcast(:invalid)
            end
          end

          context "when documents and gallery are allowed" do
            let(:component) { create(:proposal_component, :with_attachments_allowed) }
            let(:uploaded_files) { [{ file: upload_test_file(Decidim::Dev.asset("Exampledocument.pdf"), content_type: "application/pdf") }] }

            it "Create gallery and documents for the proposal" do
              expect { command.call }.to change(Decidim::Attachment, :count).by(1)
            end
          end

          context "when gallery are allowed" do
            let(:component) { create(:proposal_component, :with_attachments_allowed) }
            let(:uploaded_files) { [{ file: upload_test_file(Decidim::Dev.asset("city.jpeg"), content_type: "image/jpeg") }] }

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
