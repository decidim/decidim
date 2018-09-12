# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe CreateProposal do
      let(:form_klass) { ProposalForm }
      let(:component) { create(:proposal_component) }
      let(:organization) { component.organization }
      let(:user) { create :user, :admin, :confirmed, organization: organization }
      let(:form) do
        form_klass.from_params(
          form_params
        ).with_context(
          current_user: user,
          current_organization: organization,
          current_participatory_space: component.participatory_space,
          current_component: component
        )
      end

      let(:author) { create(:user, organization: organization) }

      let(:user_group) do
        create(:user_group, :verified, organization: organization, users: [author])
      end

      describe "call" do
        let(:form_params) do
          {
            title: "A reasonable proposal title",
            body: "A reasonable proposal body",
            user_group_id: user_group.try(:id)
          }
        end

        let(:command) do
          described_class.new(form, author)
        end

        describe "when the form is not valid" do
          before do
            expect(form).to receive(:invalid?).and_return(true)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't create a proposal" do
            expect do
              command.call
            end.not_to change(Decidim::Proposals::Proposal, :count)
          end
        end

        describe "when the form is valid" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "creates a new proposal" do
            expect do
              command.call
            end.to change(Decidim::Proposals::Proposal, :count).by(1)
          end

          context "with an author" do
            let(:user_group) { nil }

            it "adds the author as a follower" do
              command.call
              proposal = Decidim::Proposals::Proposal.last

              expect(proposal.followers).to include(author)
            end

            context "with a proposal limit" do
              let(:component) do
                create(:proposal_component, settings: { "proposal_limit" => 2 })
              end

              it "checks the author doesn't exceed the amount of proposals" do
                expect { command.call }.to broadcast(:ok)
                expect { command.call }.to broadcast(:ok)
                expect { command.call }.to broadcast(:invalid)
              end
            end
          end

          describe "the proposal limit excludes withdrawn proposals" do
            let(:component) do
              create(:proposal_component, settings: { "proposal_limit" => 1 })
            end

            describe "when the author is a user" do
              let(:user_group) { nil }

              before do
                create(:proposal, :withdrawn, author: author, component: component)
              end

              it "checks the user doesn't exceed the amount of proposals" do
                expect { command.call }.to broadcast(:ok)
                expect { command.call }.to broadcast(:invalid)

                user_proposal_count = Decidim::Proposals::Proposal.where(author: author, component: component).count
                expect(user_proposal_count).to eq(2)
              end
            end
          end
        end
      end
    end
  end
end
