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

    # The role checks of each participatory space module (participatory processes, assemblies,
    # conferences) are covered in the specs of those modules. This spec covers the behaviour
    # shared by all of them.
    describe "#user_has_any_role?" do
      it "returns false when the user is nil" do
        expect(checker.send(:user_has_any_role?, nil)).to be(false)
      end

      context "when the user has no role" do
        it "returns false" do
          expect(checker.send(:user_has_any_role?, user)).to be(false)
        end
      end

      context "when the user is an organization admin" do
        let(:user) { create(:user, :admin, organization:) }

        it "returns true" do
          expect(checker.send(:user_has_any_role?, user)).to be(true)
        end
      end

      context "when the user has a global role" do
        let(:user) { create(:user, :user_manager, organization:) }

        it "returns true" do
          expect(checker.send(:user_has_any_role?, user)).to be(true)
        end
      end
    end

    describe "#space_user_role?" do
      context "when the user has no role" do
        it "returns false for the given participatory process" do
          expect(checker.send(:space_user_role?, user, participatory_process)).to be(false)
        end

        it "returns false without any space" do
          expect(checker.send(:space_user_role?, user, nil)).to be(false)
        end
      end

      context "when the participatory_processes module is not installed" do
        before do
          create(:participatory_process_user_role, user:, participatory_process:)

          allow(Decidim).to receive(:module_installed?).and_call_original
          allow(Decidim).to receive(:module_installed?).with(:participatory_processes).and_return(false)
          hide_const("Decidim::ParticipatoryProcess")
        end

        it "does not evaluate the missing module class" do
          expect { checker.send(:space_user_role?, user, participatory_process) }.not_to raise_error
        end

        it "returns false for a space of the missing module" do
          expect(checker.send(:space_user_role?, user, participatory_process)).to be(false)
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

      context "when the user is an organization admin" do
        let(:user) { create(:user, :admin, organization:) }

        it "does not query any role table when a broad check is requested" do
          queries = role_table_queries do
            checker.send(:user_has_any_role?, user, participatory_process, broad_check: true)
          end

          expect(queries).to be_empty
        end
      end

      context "when the user has a global role" do
        let(:user) { create(:user, :user_manager, organization:) }

        it "does not query any role table when a broad check is requested" do
          queries = role_table_queries do
            checker.send(:user_has_any_role?, user, participatory_process, broad_check: true)
          end

          expect(queries).to be_empty
        end
      end

      context "when the user has a space role" do
        before { create(:participatory_process_user_role, user:, participatory_process:) }

        it "does not repeat a broad role query within the same checker instance" do
          first = role_table_queries { checker.send(:user_has_any_role?, user, nil, broad_check: true) }
          second = role_table_queries { checker.send(:user_has_any_role?, user, nil, broad_check: true) }

          expect(first.size).to be <= 3
          expect(second).to be_empty
        end
      end
    end
  end
end
