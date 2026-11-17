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
    let(:participatory_process) { create(:participatory_process, organization:) }

    describe "#user_has_any_role?" do
      context "with a participatory process" do
        context "when the user has a role in the given participatory process" do
          before { create(:participatory_process_user_role, user:, participatory_process:) }

          it "returns true" do
            expect(checker.send(:user_has_any_role?, user, participatory_process)).to be(true)
          end
        end

        context "when the user has a role in another participatory process" do
          let(:other_participatory_process) { create(:participatory_process, organization:) }

          before { create(:participatory_process_user_role, user:, participatory_process: other_participatory_process) }

          it "returns false" do
            expect(checker.send(:user_has_any_role?, user, participatory_process)).to be(false)
          end

          it "returns true with a broad check" do
            expect(checker.send(:user_has_any_role?, user, participatory_process, broad_check: true)).to be(true)
          end
        end
      end
    end

    context "when the user has a role in a trashed participatory process" do
      let(:trashed_participatory_process) { create(:participatory_process, organization:) }

      before do
        create(:participatory_process_user_role, user:, participatory_process: trashed_participatory_process)
        trashed_participatory_process.destroy
      end

      it "returns false with a broad check, as trashed participatory process roles do not grant access" do
        expect(checker.send(:user_has_any_role?, user, participatory_process, broad_check: true)).to be(false)
      end
    end

    describe "#space_user_role?" do
      context "when the user has a role in the given participatory process" do
        before { create(:participatory_process_user_role, user:, participatory_process:) }

        it "returns true" do
          expect(checker.send(:space_user_role?, user, participatory_process)).to be(true)
        end

        it "returns true with a broad check" do
          expect(checker.send(:space_user_role?, user, nil, broad_check: true)).to be(true)
        end
      end

      context "when the user has a role in another participatory process" do
        let(:another_participatory_process) { create(:participatory_process, organization:) }

        before { create(:participatory_process_user_role, user:, participatory_process: another_participatory_process) }

        it "returns false for the given participatory process" do
          expect(checker.send(:space_user_role?, user, participatory_process)).to be(false)
        end
      end

      context "when the user has a role in an assembly" do
        let(:assembly) { create(:assembly, organization:) }

        before { create(:assembly_user_role, user:, assembly:) }

        it "returns false for the given participatory process" do
          expect(checker.send(:space_user_role?, user, participatory_process)).to be(false)
        end
      end

      context "when another module is not installed" do
        before do
          create(:participatory_process_user_role, user:, participatory_process:)

          allow(Decidim).to receive(:module_installed?).and_call_original
          allow(Decidim).to receive(:module_installed?).with(:assemblies).and_return(false)
          hide_const("Decidim::Assembly")
        end

        it "returns true for a space of an installed module" do
          expect(checker.send(:space_user_role?, user, participatory_process)).to be(true)
        end

        it "returns true with a broad check" do
          expect(checker.send(:space_user_role?, user, nil, broad_check: true)).to be(true)
        end
      end
    end

    describe "#participatory_process_user_role?" do
      context "when the user has a role in the given participatory process" do
        before { create(:participatory_process_user_role, user:, participatory_process:) }

        it "returns true" do
          expect(checker.send(:participatory_process_user_role?, user, participatory_process)).to be(true)
        end
      end

      context "when the user has a role in another participatory process" do
        let(:other_participatory_process) { create(:participatory_process, organization:) }

        before { create(:participatory_process_user_role, user:, participatory_process: other_participatory_process) }

        it "returns false for the given participatory process" do
          expect(checker.send(:participatory_process_user_role?, user, participatory_process)).to be(false)
        end
      end

      context "when the user has no role" do
        it "returns false" do
          expect(checker.send(:participatory_process_user_role?, user, participatory_process)).to be(false)
        end
      end

      context "when no participatory process is given" do
        before { create(:participatory_process_user_role, user:, participatory_process:) }

        it "returns false" do
          expect(checker.send(:participatory_process_user_role?, user)).to be(false)
        end
      end

      context "with a broad check" do
        before { create(:participatory_process_user_role, user:, participatory_process:) }

        it "returns true without a participatory process" do
          expect(checker.send(:participatory_process_user_role?, user, nil, broad_check: true)).to be(true)
        end

        it "returns true for another participatory process" do
          other_participatory_process = create(:participatory_process, organization:)

          expect(checker.send(:participatory_process_user_role?, user, other_participatory_process, broad_check: true)).to be(true)
        end
      end

      context "when the given space is not a participatory process" do
        let(:assembly) { create(:assembly, organization:) }

        before { create(:participatory_process_user_role, user:, participatory_process:) }

        it "returns false" do
          expect(checker.send(:participatory_process_user_role?, user, assembly)).to be(false)
        end
      end

      context "when the participatory processes module is not installed" do
        before do
          allow(Decidim).to receive(:module_installed?).with(:participatory_processes).and_return(false)
          create(:participatory_process_user_role, user:, participatory_process:)
        end

        it "returns false" do
          expect(checker.send(:participatory_process_user_role?, user, participatory_process)).to be(false)
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
        before { create(:participatory_process_user_role, user:, participatory_process:) }

        it "does not repeat the role query within the same checker instance" do
          first = role_table_queries { checker.send(:user_has_any_role?, user, participatory_process) }
          second = role_table_queries { checker.send(:user_has_any_role?, user, participatory_process) }

          expect(first.size).to eq(1)
          expect(second).to be_empty
        end
      end

      context "with a broad check and a concrete space" do
        before { create(:participatory_process_user_role, user:, participatory_process:) }

        it "only queries the participatory processes role table" do
          queries = role_table_queries do
            checker.send(:user_has_any_role?, user, participatory_process, broad_check: true)
          end

          expect(queries.size).to eq(1)
          expect(queries.first).to include("decidim_participatory_process_user_roles")
        end
      end

      def user_id_index?(table)
        ActiveRecord::Base.connection.index_exists?(table, :decidim_user_id)
      end

      describe "user role table indexes" do
        it "indexes decidim_user_id on the participatory processes user roles table" do
          expect(user_id_index?(:decidim_participatory_process_user_roles)).to be(true)
        end
      end
    end
  end
end
