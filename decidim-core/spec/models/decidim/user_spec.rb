# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe User do
    subject { user }

    let(:organization) { create(:organization) }
    let(:user) { build(:user, organization:) }

    include_examples "resourceable"

    it { is_expected.to be_valid }

    it "has traceability" do
      expect(subject).to be_a(Decidim::Traceable)
    end

    it "overwrites the log presenter" do
      expect(described_class.log_presenter_class_for(:foo))
        .to eq Decidim::AdminLog::UserPresenter
    end

    it "has an association for identities" do
      expect(subject.identities).to eq([])
    end

    it "has an association for user groups" do
      user_group = create(:user_group)
      create(:user_group_membership, user: subject, user_group:)
      expect(subject.user_groups).to eq([user_group])
    end

    describe "name" do
      context "when it has a name" do
        let(:user) { build(:user, name: "Oriol") }

        it "returns the name" do
          expect(user.name).to eq("Oriol")
        end
      end

      context "when it doesn't have a name" do
        let(:user) { build(:user, name: nil) }

        it "returns anonymous" do
          expect(user.name).to eq("Anonymous")
        end
      end

      context "when the user is blocked and extended_data has user_name" do
        let(:user) { build(:user, name: "Blocked user", blocked: true, extended_data: { user_name: "Test" }) }

        it "returns user name" do
          expect(user.user_name).to eq("Test")
        end
      end

      context "when the user is blocked and extended_data does not have user_name" do
        let(:user) { build(:user, name: "Blocked user", blocked: true, extended_data: {}) }

        it "returns user name" do
          expect(user.user_name).to eq("Blocked user")
        end
      end
    end

    describe "validations" do
      context "when the nickname is empty" do
        before do
          user.nickname = ""
        end

        it "is not valid" do
          expect(user).not_to be_valid
          expect(user.errors[:nickname]).to include("can't be blank")
        end

        it "can't be empty backed by an index" do
          expect { user.save(validate: false) }.not_to raise_error
        end

        context "when managed" do
          before do
            user.managed = true
          end

          it "is valid" do
            expect(user).to be_valid
          end

          it "can be saved" do
            expect(user.save).to be true
          end

          it "can have duplicates" do
            user.save!

            expect do
              create(:user, organization: user.organization,
                            nickname: user.nickname,
                            managed: true)
            end.not_to raise_error
          end
        end

        context "when deleted" do
          before do
            user.deleted_at = Time.current
          end

          it "is valid" do
            expect(user).to be_valid
          end

          it "can be saved" do
            expect(user.save).to be true
          end

          it "can have duplicates" do
            user.save!

            expect do
              create(:user, organization: user.organization,
                            nickname: user.nickname,
                            deleted_at: Time.current)
            end.not_to raise_error
          end
        end
      end

      context "when the nickname is not empty" do
        before do
          user.nickname = "a-nickname"
        end

        it "can be created" do
          expect(user.save).to be(true)
        end

        it "can't have duplicates even when skipping validations" do
          user.save!

          expect do
            build(:user, organization: user.organization,
                         nickname: user.nickname).save(validate: false)
          end.to raise_error(ActiveRecord::RecordNotUnique)
        end
      end

      context "when the file is too big" do
        before do
          expect(subject.avatar.blob).to receive(:byte_size).at_least(:once).and_return(11.megabytes)
        end

        it { is_expected.not_to be_valid }
      end

      context "when the file is a malicious image" do
        let(:avatar_path) { Decidim::Dev.asset("malicious.jpg") }
        let(:user) do
          build(
            :user,
            avatar: ActiveStorage::Blob.create_and_upload!(
              io: File.open(avatar_path),
              filename: "malicious.jpeg",
              content_type: "image/jpeg"
            )
          )
        end

        it { is_expected.not_to be_valid }
      end

      context "with weird characters" do
        let(:weird_characters) do
          ["<", ">", "?", "%", "&", "^", "*", "#", "@", "(", ")", "[", "]", "=", "+", ":", ";", '"', "{", "}", " |"]
        end

        it "doesn't allow them" do
          weird_characters.each do |character|
            user = build(:user)
            user.name.insert(rand(0..user.name.length), character)
            user.nickname.insert(rand(0..user.nickname.length), character)

            expect(user).not_to be_valid
            expect(user.errors[:name].length).to eq(1)
            expect(user.errors[:nickname].length).to eq(1)
          end
        end
      end
    end

    describe "validation scopes" do
      context "when a user with the same email exists in another organization" do
        let(:email) { "foo@bar.com" }
        let(:user) { create(:user, email:) }

        before do
          create(:user, email:)
        end

        it { is_expected.to be_valid }
      end
    end

    describe "devise emails" do
      it "sends them asynchronously" do
        create(:user)
        expect(ActionMailer::MailDeliveryJob).to have_been_enqueued.on_queue("mailers")
      end
    end

    describe "#deleted?" do
      it "returns true if deleted_at is present" do
        subject.deleted_at = Time.current
        expect(subject).to be_deleted
      end
    end

    describe "#tos_accepted?" do
      subject { user.tos_accepted? }

      let(:user) { create(:user, organization:, accepted_tos_version:) }
      let(:accepted_tos_version) { organization.tos_version }

      it { is_expected.to be_truthy }

      context "when user accepted ToS before organization last update" do
        let(:organization) { build(:organization, tos_version: Time.current) }
        let(:accepted_tos_version) { 1.year.before }

        it { is_expected.to be_falsey }

        context "when organization has no TOS" do
          let(:organization) { build(:organization, tos_version: nil) }
          let(:user) { build(:user, organization:) }

          it { is_expected.to be_falsey }
        end
      end

      context "when user didn't accepted ToS" do
        let(:accepted_tos_version) { nil }

        it { is_expected.to be_falsey }

        context "when user is managed" do
          let(:user) { build(:user, :managed, organization:, accepted_tos_version:) }

          it { is_expected.to be_truthy }
        end

        context "when organization has no TOS" do
          let(:organization) { build(:organization, tos_version: nil) }

          it { is_expected.to be_falsey }
        end
      end
    end

    describe "#find_for_authentication" do
      let(:user) { create(:user, organization:) }

      let(:conditions) do
        {
          env: {
            "decidim.current_organization" => organization
          },
          email: user.email.upcase
        }
      end

      it "finds the user even with weird casing in email" do
        expect(described_class.find_for_authentication(conditions)).to eq user
      end
    end

    describe ".interested_in_scopes" do
      let(:scopes) { [] }

      let(:scope1) { create(:scope, organization:) }
      let(:scope2) { create(:scope, organization:) }
      let(:scope3) { create(:scope, organization:) }
      let(:scope4) { create(:scope, organization:) }
      let(:scope5) { create(:scope, organization:) }

      let(:users_scope1) { create_list(:user, 10, organization:, extended_data: { interested_scopes: scope1.id }) }
      let(:users_scope2) { create_list(:user, 10, organization:, extended_data: { interested_scopes: [scope2.id] }) }
      let(:users_multiscope) { create_list(:user, 10, organization:, extended_data: { interested_scopes: [scope1.id, scope2.id, scope3.id] }) }

      # It needs to be controlled when the users are created which is why this
      # needs to be separated to its own method instead of using the bang
      # method assignments.
      def create_users_and_scopes
        scope1
        scope2
        scope3
        scope4
        scope5
        users_scope1
        users_scope2
        users_multiscope
      end

      context "when searching with an empty array" do
        before { create_users_and_scopes }

        it "finds all users" do
          expect(described_class.interested_in_scopes(scopes).count).to eq(Decidim::User.count)
        end
      end

      context "when searching with an array containing empty values" do
        let(:scopes) { ["", nil] }

        before { create_users_and_scopes }

        it "finds all users" do
          expect(described_class.interested_in_scopes(scopes).count).to eq(Decidim::User.count)
        end
      end

      context "when searching with a single scope" do
        let(:scopes) { [scope1.id] }

        before { create_users_and_scopes }

        it "finds the correct users interested in particular scope" do
          expected_ids = users_scope1.map(&:id) + users_multiscope.map(&:id)
          actual_ids = described_class.interested_in_scopes(scopes).pluck(:id)
          expect(actual_ids.count).to eq(expected_ids.count)
          expect(actual_ids).to match_array(expected_ids)
        end
      end

      context "when searching with a multiple scopes" do
        let(:scopes) { [scope1.id, scope2.id, scope3.id, scope4.id, scope5.id] }

        before { create_users_and_scopes }

        it "finds the correct users interested in one of the scopes" do
          expected_ids = users_scope1.map(&:id) + users_scope2.map(&:id) + users_multiscope.map(&:id)
          actual_ids = described_class.interested_in_scopes(scopes).pluck(:id)
          expect(actual_ids.count).to eq(expected_ids.count)
          expect(actual_ids).to match_array(expected_ids)
        end
      end

      context "when searching with scopes no one is intereted in" do
        let(:scopes) { [scope4.id, scope5.id] }

        before { create_users_and_scopes }

        it "does not find any users" do
          expect(described_class.interested_in_scopes(scopes).count).to eq(0)
        end
      end

      context "when there are scopes with matching numbers in their IDs" do
        let(:scopes) { [scope1.id] }
        let(:extra_scopes) { create_list(:scope, 15, organization:) }
        let(:users_scope11) { create_list(:user, 10, organization:, extended_data: { interested_scopes: [11] }) }

        before do
          # Reset the scope IDs to start from 1 in order to get possibly
          # "conflicting" ID sequences for the `.interested_in_scopes` call.
          # This ensures the method that finds the matches will not consider
          # "conflicting" matches as full matches.
          ActiveRecord::Base.connection.reset_pk_sequence!(Decidim::Scope.table_name)

          create_users_and_scopes
          extra_scopes
          users_scope11
        end

        it "finds the correct users interested in particular scope" do
          expected_ids = users_scope1.map(&:id) + users_multiscope.map(&:id)
          actual_ids = described_class.interested_in_scopes(scopes).pluck(:id)
          expect(actual_ids.count).to eq(expected_ids.count)
          expect(actual_ids).to match_array(expected_ids)
        end
      end
    end
  end
end
