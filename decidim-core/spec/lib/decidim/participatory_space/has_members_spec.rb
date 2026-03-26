# frozen_string_literal: true

require "spec_helper"

module Decidim::ParticipatorySpace
  describe HasMembers do
    subject { participatory_space }

    let(:organization) { create(:organization) }
    let(:user) { create(:user, :confirmed, organization:) }
    let(:non_member_user) { create(:user, :confirmed, organization:) }
    let(:member_user) { create(:user, :confirmed, organization:) }
    let(:admin_user) { create(:user, :admin, :confirmed, organization:) }

    describe "#can_participate?" do
      context "with participatory process - open access mode" do
        let(:participatory_space) { create(:participatory_process, :open, :published, organization:) }

        it "allows everyone to participate" do
          expect(participatory_space.can_participate?(user)).to be true
          expect(participatory_space.can_participate?(non_member_user)).to be true
          expect(participatory_space.can_participate?(nil)).to be true
        end

        it "allows admin to participate" do
          expect(participatory_space.can_participate?(admin_user)).to be true
        end
      end

      context "with participatory process - restricted access mode" do
        let(:participatory_space) { create(:participatory_process, :restricted, :published, organization:) }
        let(:member_user) { create(:user, :confirmed, organization:) }

        context "when user is a member" do
          before do
            Decidim::ParticipatorySpace::Member.create(participatory_space:, user: member_user)
          end

          it "allows member to participate" do
            expect(participatory_space.can_participate?(member_user)).to be true
          end
        end

        context "when user is not a member" do
          let(:non_member_user) { create(:user, :confirmed, organization:) }

          it "does not allow non-member to participate" do
            expect(participatory_space.can_participate?(non_member_user)).to be false
          end
        end

        context "when user is nil" do
          it "does not allow participation" do
            expect(participatory_space.can_participate?(nil)).to be false
          end
        end

        context "when user is admin" do
          it "allows admin to participate" do
            expect(participatory_space.can_participate?(admin_user)).to be true
          end
        end

        context "when process is not published" do
          let(:participatory_space) { create(:participatory_process, :restricted, :unpublished, organization:) }
          let(:member_user) { create(:user, :confirmed, organization:) }

          before do
            Decidim::ParticipatorySpace::Member.create(participatory_space:, user: member_user)
          end

          it "does not allow participation" do
            expect(participatory_space.can_participate?(member_user)).to be false
            expect(participatory_space.can_participate?(admin_user)).to be false
          end
        end
      end

      context "with participatory process - transparent access mode" do
        let(:participatory_space) { create(:participatory_process, :transparent, :published, organization:) }

        context "when user is a member" do
          before do
            create(:member, user: member_user, participatory_space:)
          end

          it "allows member to participate" do
            expect(participatory_space.can_participate?(member_user)).to be true
          end
        end

        context "when user is not a member" do
          it "does not allow non-member to participate" do
            expect(participatory_space.can_participate?(non_member_user)).to be false
          end
        end

        context "when user is nil" do
          it "does not allow participation" do
            expect(participatory_space.can_participate?(nil)).to be false
          end
        end

        context "when user is admin" do
          it "allows admin to participate" do
            expect(participatory_space.can_participate?(admin_user)).to be true
          end
        end
      end

      context "with assembly - open access mode" do
        let(:participatory_space) { create(:assembly, :open, :published, organization:) }

        it "allows everyone to participate" do
          expect(participatory_space.can_participate?(user)).to be true
          expect(participatory_space.can_participate?(non_member_user)).to be true
          expect(participatory_space.can_participate?(nil)).to be true
        end
      end

      context "with assembly - restricted access mode" do
        let(:participatory_space) { create(:assembly, :restricted, :published, organization:) }
        let(:member_user) { create(:user, :confirmed, organization:) }

        context "when user is a member" do
          before do
            Decidim::ParticipatorySpace::Member.create(participatory_space:, user: member_user)
          end

          it "allows member to participate" do
            expect(participatory_space.can_participate?(member_user)).to be true
          end
        end

        context "when user is not a member" do
          let(:non_member_user) { create(:user, :confirmed, organization:) }

          it "does not allow non-member to participate" do
            expect(participatory_space.can_participate?(non_member_user)).to be false
          end
        end
      end

      context "with assembly - transparent access mode" do
        let(:participatory_space) { create(:assembly, :transparent, :published, organization:) }

        context "when user is a member" do
          before do
            create(:member, user: member_user, participatory_space:)
          end

          it "allows member to participate" do
            expect(participatory_space.can_participate?(member_user)).to be true
          end
        end

        context "when user is not a member" do
          it "does not allow non-member to participate" do
            expect(participatory_space.can_participate?(non_member_user)).to be false
          end
        end
      end

      context "with model that has access_mode" do
        let(:participatory_space) { create(:participatory_process, organization:) }

        it "allows everyone to participate by default" do
          expect(participatory_space.can_participate?(user)).to be true
          expect(participatory_space.can_participate?(nil)).to be true
        end
      end
    end

    describe ".public_spaces" do
      let(:open_process) { create(:participatory_process, :open, :published, organization:) }
      let(:transparent_process) { create(:participatory_process, :transparent, :published, organization:) }
      let(:restricted_process) { create(:participatory_process, :restricted, :published, organization:) }

      it "returns open and transparent spaces" do
        expect(Decidim::ParticipatoryProcess.public_spaces).to contain_exactly(open_process, transparent_process)
      end
    end

    describe ".private_spaces" do
      let(:open_process) { create(:participatory_process, :open, :published, organization:) }
      let(:transparent_process) { create(:participatory_process, :transparent, :published, organization:) }
      let(:restricted_process) { create(:participatory_process, :restricted, :published, organization:) }

      it "returns restricted and transparent spaces" do
        expect(Decidim::ParticipatoryProcess.private_spaces).to contain_exactly(restricted_process, transparent_process)
      end
    end
  end
end
