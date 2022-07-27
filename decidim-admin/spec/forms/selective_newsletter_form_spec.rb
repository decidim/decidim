# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe SelectiveNewsletterForm do
      subject do
        described_class.from_params(attributes).with_context(
          current_organization: organization,
          current_user: user
        )
      end

      let(:organization) { create(:organization) }
      let!(:user) { create :user, :confirmed, :admin, organization: }
      let(:scopes) do
        create_list(:scope, 5, organization:)
      end
      let(:participatory_processes) { create_list(:participatory_process, rand(1..9), organization:) }
      let(:selected_participatory_processes) { [participatory_processes.first.id.to_s] }
      let(:send_to_all_users) { user.admin? }
      let(:send_to_participants) { false }
      let(:send_to_followers) { false }
      let(:participatory_space_types) { [] }
      let(:scope_ids) { [] }

      let(:attributes) do
        {
          "newsletter" => {
            "send_to_all_users" => send_to_all_users,
            "send_to_participants" => send_to_participants,
            "send_to_followers" => send_to_followers,
            "participatory_space_types" => participatory_space_types,
            "scope_ids" => scope_ids
          }
        }
      end

      context "when everything is OK" do
        it { is_expected.to be_valid }
      end

      shared_examples_for "selective newsletter form" do
        context "when no space is selected" do
          it { is_expected.to be_invalid }
        end

        context "when some space is selected" do
          let(:participatory_space_types) do
            [
              { "id" => nil,
                "manifest_name" => "participatory_processes",
                "ids" => selected_participatory_processes },
              { "id" => nil,
                "manifest_name" => "assemblies",
                "ids" => [] },
              { "id" => nil,
                "manifest_name" => "conferences",
                "ids" => [] },
              { "id" => nil,
                "manifest_name" => "consultations",
                "ids" => [] },
              { "id" => nil,
                "manifest_name" => "initiatives",
                "ids" => [] }
            ]
          end

          it { is_expected.to be_valid }
        end
      end

      context "when send to all users is false" do
        let(:send_to_all_users) { false }

        it { is_expected.to be_invalid }

        context "when send to followers is true" do
          let(:send_to_followers) { true }

          it_behaves_like "selective newsletter form"
        end

        context "when send to participants is true" do
          let(:send_to_participants) { true }

          it_behaves_like "selective newsletter form"
        end
      end

      context "when the user is a space admin" do
        let(:user) { create(:user, organization:) }

        let(:participatory_process_user_role) do
          build(
            :participatory_process_user_role,
            user:,
            participatory_process: participatory_processes.first,
            role: "admin"
          )
        end
        let(:send_to_followers) { true }
        let(:send_to_participants) { true }

        it_behaves_like "selective newsletter form"

        context "when trying to send to all users" do
          let(:send_to_all_users) { true }

          it { is_expected.to be_invalid }
        end
      end

      describe "#scope_ids" do
        context "when the scope IDs contain an empty value" do
          # When the scope is selected from a dropdown and no value is selected
          # this is what will be sent by the form
          # (<option value="">...</option>).
          let(:scope_ids) { [""] }

          it "returns an empty array" do
            expect(subject.scope_ids.empty?).to be(true)
          end
        end
      end
    end
  end
end
