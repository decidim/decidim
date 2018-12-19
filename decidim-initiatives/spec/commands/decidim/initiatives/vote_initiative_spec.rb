# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    describe VoteInitiative do
      let(:form_klass) { VoteForm }
      let(:initiative) { create(:initiative) }

      let(:current_user) { create(:user, organization: initiative.organization) }
      let(:form) do
        form_klass
          .from_params(
            form_params
          )
      end

      let(:form_params) do
        {
          initiative_id: initiative.id,
          author_id: current_user.id
        }
      end

      let(:personal_data_params) do
        {
          name_and_surname: ::Faker::Name.name,
          document_number: ::Faker::IDNumber.spanish_citizen_number,
          date_of_birth: ::Faker::Date.birthday(18, 40),
          postal_code: ::Faker::Address.zip_code
        }
      end

      describe "User votes initiative" do
        let(:command) { described_class.new(form, current_user) }

        it "broadcasts ok" do
          expect { command.call }.to broadcast :ok
        end

        it "creates a vote" do
          expect do
            command.call
          end.to change(InitiativesVote, :count).by(1)
        end

        it "increases the vote counter by one" do
          expect do
            command.call
            initiative.reload
          end.to change(initiative, :initiative_votes_count).by(1)
        end

        it "notifies the creation" do
          follower = create(:user, organization: initiative.organization)
          create(:follow, followable: initiative.author, user: follower)

          expect(Decidim::EventsManager)
            .to receive(:publish)
            .with(
              event: "decidim.events.initiatives.initiative_endorsed",
              event_class: Decidim::Initiatives::EndorseInitiativeEvent,
              resource: initiative,
              followers: [follower]
            )

          command.call
        end

        context "when a new milestone is completed" do
          let(:organization) { create(:organization) }
          let(:initiative) do
            create(:initiative,
                   organization: organization,
                   scoped_type: create(
                     :initiatives_type_scope,
                     supports_required: 4,
                     type: create(:initiatives_type, organization: organization)
                   ))
          end

          before do
            create(:initiative_user_vote, initiative: initiative)
            create(:initiative_user_vote, initiative: initiative)
          end

          it "notifies the followers" do
            follower = create(:user, organization: initiative.organization)
            create(:follow, followable: initiative, user: follower)

            expect(Decidim::EventsManager).to receive(:publish)
              .with(kind_of(Hash))

            expect(Decidim::EventsManager)
              .to receive(:publish)
              .with(
                event: "decidim.events.initiatives.milestone_completed",
                event_class: Decidim::Initiatives::MilestoneCompletedEvent,
                resource: initiative,
                affected_users: [initiative.author],
                followers: [follower],
                extra: { percentage: 75 }
              )

            command.call
          end
        end

        context "when initiative type requires extra user fields" do
          let(:organization) { create(:organization) }
          let(:initiative) do
            create(
              :initiative,
              :with_user_extra_fields_collection,
              organization: organization
            )
          end
          let(:form_with_personal_data) do
            form_klass.from_params(form_params.merge(personal_data_params))
          end

          let(:invalid_command) { described_class.new(form, current_user) }
          let(:valid_command) { described_class.new(form_with_personal_data, current_user) }

          it "broadcasts invalid when form doesn't contain personal data" do
            expect { invalid_command.call }.to broadcast :invalid
          end

          it "broadcasts ok when form contains personal data" do
            expect { valid_command.call }.to broadcast :ok
          end
        end
      end

      describe "Organization supports initiative" do
        let(:user_group) { create(:user_group) }
        let(:user_group_membership) { create(:user_group_membership, user: current_user, user_group: user_group) }
        let(:group_form) do
          form_klass.from_params(form_params.merge(group_id: user_group.id))
        end
        let(:command) { described_class.new(group_form, current_user) }

        it "broadcasts ok" do
          expect { command.call }.to broadcast :ok
        end

        it "creates a vote" do
          expect do
            command.call
          end.to change(InitiativesVote, :count).by(1)
        end

        it "does not increases the vote counter by one" do
          command.call
          initiative.reload
          expect(initiative.initiative_votes_count).to be_zero
        end

        it "does not notify the endorsement" do
          expect(Decidim::EventsManager).not_to receive(:publish)
          command.call
        end
      end
    end
  end
end
