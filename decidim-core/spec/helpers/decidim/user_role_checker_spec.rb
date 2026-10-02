# frozen_string_literal: true

require "spec_helper"
require "decidim/conferences/test/factories"

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

      context "with a participatory process" do
        let(:participatory_process) { create(:participatory_process, organization:) }

        context "when the user has a role in the given process" do
          before { create(:participatory_process_user_role, user:, participatory_process:) }

          it "returns true" do
            expect(checker.send(:user_has_any_role?, user, participatory_process)).to be(true)
          end
        end

        context "when the user has a role in another process" do
          let(:other_process) { create(:participatory_process, organization:) }

          before { create(:participatory_process_user_role, user:, participatory_process: other_process) }

          it "returns false" do
            expect(checker.send(:user_has_any_role?, user, participatory_process)).to be(false)
          end

          it "returns true with a broad check" do
            expect(checker.send(:user_has_any_role?, user, participatory_process, broad_check: true)).to be(true)
          end
        end

        context "when the user has a role but no space is given" do
          before { create(:participatory_process_user_role, user:, participatory_process:) }

          it "returns false" do
            expect(checker.send(:user_has_any_role?, user)).to be(false)
          end

          it "returns true with a broad check" do
            expect(checker.send(:user_has_any_role?, user, nil, broad_check: true)).to be(true)
          end
        end
      end

      context "with an assembly" do
        let(:assembly) { create(:assembly, organization:) }

        context "when the user has a role in the given assembly" do
          before { create(:assembly_user_role, user:, assembly:) }

          it "returns true" do
            expect(checker.send(:user_has_any_role?, user, assembly)).to be(true)
          end
        end

        context "when the user has a role in another assembly" do
          let(:other_assembly) { create(:assembly, organization:) }

          before { create(:assembly_user_role, user:, assembly: other_assembly) }

          it "returns false" do
            expect(checker.send(:user_has_any_role?, user, assembly)).to be(false)
          end

          it "returns true with a broad check" do
            expect(checker.send(:user_has_any_role?, user, assembly, broad_check: true)).to be(true)
          end
        end
      end

      context "with a conference" do
        let(:conference) { create(:conference, organization:) }

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

    describe "#participatory_process_user_role?" do
      let(:participatory_process) { create(:participatory_process, organization:) }

      context "when the user has a role in the given process" do
        before { create(:participatory_process_user_role, user:, participatory_process:) }

        it "returns true" do
          expect(checker.send(:participatory_process_user_role?, user, participatory_process)).to be(true)
        end
      end

      context "when the user has a role in another process" do
        let(:other_process) { create(:participatory_process, organization:) }

        before { create(:participatory_process_user_role, user:, participatory_process: other_process) }

        it "returns false for the given process" do
          expect(checker.send(:participatory_process_user_role?, user, participatory_process)).to be(false)
        end
      end

      context "when the user has no role" do
        it "returns false" do
          expect(checker.send(:participatory_process_user_role?, user, participatory_process)).to be(false)
        end
      end

      context "when no process is given" do
        before { create(:participatory_process_user_role, user:, participatory_process:) }

        it "returns false" do
          expect(checker.send(:participatory_process_user_role?, user)).to be(false)
        end
      end

      context "with a broad check" do
        before { create(:participatory_process_user_role, user:, participatory_process:) }

        it "returns true without a process" do
          expect(checker.send(:participatory_process_user_role?, user, nil, broad_check: true)).to be(true)
        end

        it "returns true for another process" do
          other_process = create(:participatory_process, organization:)

          expect(checker.send(:participatory_process_user_role?, user, other_process, broad_check: true)).to be(true)
        end
      end

      context "when the given space is not a participatory process" do
        let(:assembly) { create(:assembly, organization:) }

        before { create(:participatory_process_user_role, user:, participatory_process:) }

        it "returns false" do
          expect(checker.send(:participatory_process_user_role?, user, assembly)).to be(false)
        end
      end

      context "when the participatory_processes module is not installed" do
        before do
          allow(Decidim).to receive(:module_installed?).with(:participatory_processes).and_return(false)
          create(:participatory_process_user_role, user:, participatory_process:)
        end

        it "returns false" do
          expect(checker.send(:participatory_process_user_role?, user, participatory_process)).to be(false)
        end
      end
    end

    describe "#assembly_user_role?" do
      let(:assembly) { create(:assembly, organization:) }

      context "when the user has a role in the given assembly" do
        before { create(:assembly_user_role, user:, assembly:) }

        it "returns true" do
          expect(checker.send(:assembly_user_role?, user, assembly)).to be(true)
        end
      end

      context "when the user has a role in another assembly" do
        let(:other_assembly) { create(:assembly, organization:) }

        before { create(:assembly_user_role, user:, assembly: other_assembly) }

        it "returns false for the given assembly" do
          expect(checker.send(:assembly_user_role?, user, assembly)).to be(false)
        end
      end

      context "when the user has no role" do
        it "returns false" do
          expect(checker.send(:assembly_user_role?, user, assembly)).to be(false)
        end
      end

      context "when no assembly is given" do
        before { create(:assembly_user_role, user:, assembly:) }

        it "returns false" do
          expect(checker.send(:assembly_user_role?, user)).to be(false)
        end
      end

      context "with a broad check" do
        before { create(:assembly_user_role, user:, assembly:) }

        it "returns true without an assembly" do
          expect(checker.send(:assembly_user_role?, user, nil, broad_check: true)).to be(true)
        end

        it "returns true for another assembly" do
          other_assembly = create(:assembly, organization:)

          expect(checker.send(:assembly_user_role?, user, other_assembly, broad_check: true)).to be(true)
        end
      end

      context "when the given space is not an assembly" do
        let(:participatory_process) { create(:participatory_process, organization:) }

        before { create(:assembly_user_role, user:, assembly:) }

        it "returns false" do
          expect(checker.send(:assembly_user_role?, user, participatory_process)).to be(false)
        end
      end

      context "when the assemblies module is not installed" do
        before do
          allow(Decidim).to receive(:module_installed?).with(:assemblies).and_return(false)
          create(:assembly_user_role, user:, assembly:)
        end

        it "returns false" do
          expect(checker.send(:assembly_user_role?, user, assembly)).to be(false)
        end
      end
    end

    describe "#conference_user_role?" do
      let(:conference) { create(:conference, organization:) }

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
  end
end
