# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe UpdateCollaborativeDraft do
      let(:form_klass) { CollaborativeDraftForm }

      let(:component) { create(:proposal_component) }
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

      let!(:collaborative_draft) { create :collaborative_draft, component: component, users: [author] }
      let(:author) { create(:user, organization: organization) }

      let(:user_group) do
        create(:user_group, :verified, organization: organization, users: [author])
      end

      let(:has_address) { false }
      let(:address) { nil }
      let(:latitude) { 40.1234 }
      let(:longitude) { 2.1234 }

      describe "call" do
        let(:form_params) do
          {
            title: "This is the collaborative draft title",
            body: "This is the collaborative draft body",
            address: address,
            has_address: has_address,
            user_group_id: user_group.try(:id)
          }
        end

        let(:command) do
          described_class.new(form, author, collaborative_draft)
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
            end.not_to change(collaborative_draft, :title)
          end
        end

        describe "when the collaborative draft is not editable by the user" do
          before do
            expect(collaborative_draft).to receive(:editable_by?).and_return(false)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't update the collaborative draft" do
            expect do
              command.call
            end.not_to change(collaborative_draft, :title)
          end
        end

        describe "when the form is valid" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "updates the collaborative draft" do
            expect do
              command.call
            end.to change(collaborative_draft, :title)
          end

          it "creates a new version for the collaborative draft", versioning: true do
            expect do
              command.call
            end.to change { collaborative_draft.versions.count }.by(1)
            expect(collaborative_draft.versions.last.whodunnit).to eq author.to_gid.to_s
          end

          context "with an author" do
            let(:user_group) { nil }

            it "sets the author" do
              command.call
              collaborative_draft = Decidim::Proposals::CollaborativeDraft.last

              expect(collaborative_draft.coauthorships.count).to eq(1)
              expect(collaborative_draft.authors.count).to eq(1)
              expect(collaborative_draft.authors.first).to eq(author)
            end
          end

          context "when geocoding is enabled" do
            let(:component) { create(:proposal_component, :with_geocoding_enabled) }

            context "when the has address checkbox is checked" do
              let(:has_address) { true }

              context "when the address is present" do
                let(:address) { "Carrer Pare Llaurador 113, baixos, 08224 Terrassa" }

                before do
                  Geocoder::Lookup::Test.add_stub(
                    address,
                    [{ "latitude" => latitude, "longitude" => longitude }]
                  )
                end

                it "sets the latitude and longitude" do
                  command.call
                  collaborative_draft = Decidim::Proposals::CollaborativeDraft.last

                  expect(collaborative_draft.latitude).to eq(latitude)
                  expect(collaborative_draft.longitude).to eq(longitude)
                end
              end
            end
          end
        end
      end
    end
  end
end
