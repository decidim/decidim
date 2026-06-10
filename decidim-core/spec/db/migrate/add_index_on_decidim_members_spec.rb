# frozen_string_literal: true

require "spec_helper"
require_relative "../../../db/migrate/20260314081619_add_index_on_decidim_members"

describe "AddIndexOnDecidimMembers", type: :migration do
  let(:organization) { create(:organization) }
  let(:user1) { create(:user, :confirmed, organization:) }
  let(:user2) { create(:user, :confirmed, organization:) }
  let(:participatory_space1) { create(:participatory_process, organization:) }
  let(:participatory_space2) { create(:participatory_process, organization:) }

  let(:member_class) { Decidim::ParticipatorySpace::Member }

  before do
    if ActiveRecord::Base.connection.index_exists?(:decidim_members, name: "unique_space_members")
      ActiveRecord::Base.connection.remove_index(:decidim_members, name: "unique_space_members")
    end
  end

  # Restore the index after tests
  after do
    unless ActiveRecord::Base.connection.index_exists?(:decidim_members, name: "unique_space_members")
      ActiveRecord::Base.connection.add_index(:decidim_members,
                                              [:decidim_user_id, :participatory_space_type, :participatory_space_id],
                                              name: "unique_space_members",
                                              unique: true)

    end
  end

  def create_member(user_id:, space_id:, space_type:, role: "role")
    user = user_id.nil? ? nil : Decidim::User.find(user_id)
    space = space_type.constantize.find(space_id)
    member = build(:member, user:, participatory_space: space, role: { en: role }, published: true)
    member.save!(validate: false)
  end

  describe "#migrate :up" do
    let(:migration) { AddIndexOnDecidimMembers.new }

    context "when there are rows with nil decidim_user_id" do
      before do
        create_member(user_id: nil, space_id: participatory_space1.id, space_type: participatory_space1.class.name)
      end

      it "removes rows with nil decidim_user_id" do
        members = member_class.where(decidim_user_id: nil)
        expect(members.count).to eq(1)

        migration.migrate(:up)

        expect(members.count).to eq(0)
      end
    end

    context "when there are duplicate users in the same space" do
      before do
        create_member(user_id: user1.id, space_id: participatory_space1.id, space_type: participatory_space1.class.name, role: "role1")
        create_member(user_id: user1.id, space_id: participatory_space1.id, space_type: participatory_space1.class.name, role: "role2")
      end

      it "removes duplicates keeping the one with highest id" do
        members = member_class.where(decidim_user_id: user1.id, participatory_space_id: participatory_space1.id)
        expect(members.count).to eq(2)

        migration.migrate(:up)

        expect(members.count).to eq(1)
      end
    end

    context "when there are duplicates across different spaces" do
      before do
        create_member(user_id: user1.id, space_id: participatory_space1.id, space_type: participatory_space1.class.name, role: "role1")
        create_member(user_id: user1.id, space_id: participatory_space2.id, space_type: participatory_space2.class.name, role: "role2")
      end

      it "keeps members from different spaces" do
        members = member_class.where(decidim_user_id: user1.id)
        expect(members.count).to eq(2)

        migration.migrate(:up)

        expect(members.count).to eq(2)
      end
    end

    context "when adding the unique index" do
      before do
        create_member(user_id: user1.id, space_id: participatory_space1.id, space_type: participatory_space1.class.name)
        create_member(user_id: user2.id, space_id: participatory_space2.id, space_type: participatory_space2.class.name)
      end

      it "adds a unique index on the composite columns" do
        migration.migrate(:up)

        expect do
          create_member(user_id: user1.id, space_id: participatory_space1.id, space_type: participatory_space1.class.name, role: "another_role")
        end.to raise_error(ActiveRecord::RecordNotUnique)
      end
    end

    context "with valid data" do
      before do
        create_member(user_id: user1.id, space_id: participatory_space1.id, space_type: participatory_space1.class.name)
        create_member(user_id: user2.id, space_id: participatory_space1.id, space_type: participatory_space1.class.name)
        create_member(user_id: user1.id, space_id: participatory_space2.id, space_type: participatory_space2.class.name)
      end

      it "creates the unique index successfully" do
        migration.migrate(:up)
        expect(member_class.count).to eq(3)
      end
    end
  end

  describe "#migrate :down" do
    let(:migration) { AddIndexOnDecidimMembers.new }

    it "raises IrreversibleMigration" do
      expect { migration.migrate(:down) }.to raise_error(ActiveRecord::IrreversibleMigration)
    end
  end
end
