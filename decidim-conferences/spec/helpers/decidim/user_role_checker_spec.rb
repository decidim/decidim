# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe UserRoleChecker do
    subject(:checker) { checker_class.new }

    let(:checker_class) do
      Class.new do
        include Decidim::UserRoleChecker
      end
    end

    let(:organization) { create(:organization) }
    let(:user) { create(:user, organization:) }
    let(:conference) { create(:conference, organization:) }

    describe "#user_has_any_role?" do
      context "with a conference" do
        context "when the user has a role in the given conference" do
          before { create(:conference_user_role, user:, conference:) }

          it "returns true" do
            expect(checker.send(:user_has_any_role?, user, conference)).to be(true)
          end
        end

        context "when the user has a role in another conference" do
          let(:other_conference) { create(:conference, organization:) }

          before { create(:conference_user_role, user:, conference: other_conference) }

          it "returns false" do
            expect(checker.send(:user_has_any_role?, user, conference)).to be(false)
          end

          it "returns true with a broad check" do
            expect(checker.send(:user_has_any_role?, user, conference, broad_check: true)).to be(true)
          end
        end
      end
    end

    describe "#space_user_role?" do
      context "when the user has a role in the given conference" do
        before { create(:conference_user_role, user:, conference:) }

        it "returns true" do
          expect(checker.send(:space_user_role?, user, conference)).to be(true)
        end

        it "returns true with a broad check" do
          expect(checker.send(:space_user_role?, user, nil, broad_check: true)).to be(true)
        end
      end

      context "when the user has a role in another conference" do
        let(:another_conference) { create(:conference, organization:) }

        before { create(:conference_user_role, user:, conference: another_conference) }

        it "returns false for the given conference" do
          expect(checker.send(:space_user_role?, user, conference)).to be(false)
        end
      end

      context "when the conferences module is not installed" do
        before do
          create(:conference_user_role, user:, conference:)

          allow(Decidim).to receive(:module_installed?).and_call_original
          allow(Decidim).to receive(:module_installed?).with(:conferences).and_return(false)
          hide_const("Decidim::Conference")
        end

        it "does not evaluate the missing module class" do
          expect { checker.send(:space_user_role?, user, conference) }.not_to raise_error
        end

        it "returns false for a space of the missing module" do
          expect(checker.send(:space_user_role?, user, conference)).to be(false)
        end
      end

      context "when the participatory_processes module is not installed" do
        before do
          create(:conference_user_role, user:, conference:)

          allow(Decidim).to receive(:module_installed?).and_call_original
          allow(Decidim).to receive(:module_installed?).with(:participatory_processes).and_return(false)
          hide_const("Decidim::ParticipatoryProcess")
        end

        it "returns true for a space of an installed module" do
          expect(checker.send(:space_user_role?, user, conference)).to be(true)
        end

        it "returns true with a broad check" do
          expect(checker.send(:space_user_role?, user, nil, broad_check: true)).to be(true)
        end
      end
    end

    describe "#conference_user_role?" do
      context "when the user has a role in the given conference" do
        before { create(:conference_user_role, user:, conference:) }

        it "returns true" do
          expect(checker.send(:conference_user_role?, user, conference)).to be(true)
        end
      end

      context "when the user has a role in another conference" do
        let(:other_conference) { create(:conference, organization:) }

        before { create(:conference_user_role, user:, conference: other_conference) }

        it "returns false for the given conference" do
          expect(checker.send(:conference_user_role?, user, conference)).to be(false)
        end
      end

      context "when the user has no role" do
        it "returns false" do
          expect(checker.send(:conference_user_role?, user, conference)).to be(false)
        end
      end

      context "when no conference is given" do
        before { create(:conference_user_role, user:, conference:) }

        it "returns false" do
          expect(checker.send(:conference_user_role?, user)).to be(false)
        end
      end

      context "with a broad check" do
        before { create(:conference_user_role, user:, conference:) }

        it "returns true without a conference" do
          expect(checker.send(:conference_user_role?, user, nil, broad_check: true)).to be(true)
        end

        it "returns true for another conference" do
          other_conference = create(:conference, organization:)

          expect(checker.send(:conference_user_role?, user, other_conference, broad_check: true)).to be(true)
        end
      end

      context "when the given space is not a conference" do
        let(:assembly) { create(:assembly, organization:) }

        before { create(:conference_user_role, user:, conference:) }

        it "returns false" do
          expect(checker.send(:conference_user_role?, user, assembly)).to be(false)
        end
      end

      context "when the conferences module is not installed" do
        before do
          allow(Decidim).to receive(:module_installed?).with(:conferences).and_return(false)
          create(:conference_user_role, user:, conference:)
        end

        it "returns false" do
          expect(checker.send(:conference_user_role?, user, conference)).to be(false)
        end
      end
    end

    describe "query efficiency" do
      def role_table_queries
        queries = []
        callback = lambda do |_name, _start, _finish, _id, payload|
          sql = payload[:sql]
          queries << sql if sql&.match?(/decidim_(?:participatory_process|assembly|conference)_user_roles/)
        end

        ActiveSupport::Notifications.subscribed(callback, "sql.active_record") do
          yield
        end

        queries
      end

      context "when the same check is repeated" do
        before { create(:conference_user_role, user:, conference:) }

        it "does not repeat the role query within the same checker instance" do
          first = role_table_queries { checker.send(:user_has_any_role?, user, conference) }
          second = role_table_queries { checker.send(:user_has_any_role?, user, conference) }

          expect(first.size).to eq(1)
          expect(second).to be_empty
        end
      end

      context "with a broad check and a concrete space" do
        before { create(:conference_user_role, user:, conference:) }

        it "only queries the conference role table" do
          queries = role_table_queries do
            checker.send(:user_has_any_role?, user, conference, broad_check: true)
          end

          expect(queries.size).to eq(1)
          expect(queries.first).to include("decidim_conference_user_roles")
        end
      end

      def user_id_index?(table)
        ActiveRecord::Base.connection.index_exists?(table, :decidim_user_id)
      end

      describe "user role table indexes" do
        it "indexes decidim_user_id on the conference user roles table" do
          expect(user_id_index?(:decidim_conference_user_roles)).to be(true)
        end
      end
    end
  end
end
