# frozen_string_literal: true

require "spec_helper"

require "./db/data/20251213075429_rename_members_in_action_log"

describe RenameMembersInActionLog do
  let(:migrator) do
    described_class.new.tap do |m|
      m.verbose = false
    end
  end

  describe "#up" do
    let(:old_resource_type) { "Decidim::ParticipatorySpacePrivateUser" }
    let(:new_resource_type) { "Decidim::ParticipatorySpace::Member" }
    let(:organization) { create(:organization) }

    context "when there are records with the old resource type" do
      let!(:action_logs_with_old_type) do
        user = create(:user, organization:)
        # rubocop:disable Rails/SkipsModelValidations
        Decidim::ActionLog.insert_all([
                                        {
                                          decidim_organization_id: organization.id,
                                          user_id: user.id,
                                          user_type: user.class.name,
                                          resource_type: old_resource_type,
                                          resource_id: 1,
                                          action: "create",
                                          visibility: "admin-only",
                                          extra: {},
                                          created_at: Time.current,
                                          updated_at: Time.current
                                        },
                                        {
                                          decidim_organization_id: organization.id,
                                          user_id: user.id,
                                          user_type: user.class.name,
                                          resource_type: old_resource_type,
                                          resource_id: 2,
                                          action: "create",
                                          visibility: "admin-only",
                                          extra: {},
                                          created_at: Time.current,
                                          updated_at: Time.current
                                        },
                                        {
                                          decidim_organization_id: organization.id,
                                          user_id: user.id,
                                          user_type: user.class.name,
                                          resource_type: old_resource_type,
                                          resource_id: 3,
                                          action: "create",
                                          visibility: "admin-only",
                                          extra: {},
                                          created_at: Time.current,
                                          updated_at: Time.current
                                        }
                                      ])
      end
      # rubocop:enable Rails/SkipsModelValidations
      let!(:action_logs_with_other_types) do
        create_list(:action_log, 2, resource: create(:dummy_resource, organization:))
      end

      it "updates all records with the old resource type to the new one" do
        expect { migrator.migrate(:up) }.to change {
          Decidim::ActionLog.where(resource_type: old_resource_type).count
        }.from(3).to(0)

        expect(Decidim::ActionLog.where(resource_type: new_resource_type).count).to eq(3)
      end

      it "does not affect records with other resource types" do
        expect { migrator.migrate(:up) }.not_to(change do
          Decidim::ActionLog.where(resource_type: "Decidim::SomeOtherModel").count
        end)
      end

      it "logs the number of updated records" do
        allow(Rails.logger).to receive(:info)

        migrator.migrate(:up)

        expect(Rails.logger).to have_received(:info).with("Updated 3 ActionLog records from Decidim::ParticipatorySpacePrivateUser to Decidim::ParticipatorySpace::Member")
      end
    end

    context "when there are no records with the old resource type" do
      let!(:action_logs_with_other_types) do
        create_list(:action_log, 2, resource: create(:dummy_resource, organization:))
      end

      it "does not raise an error" do
        expect { migrator.migrate(:up) }.not_to raise_error
      end

      it "logs that zero records were updated" do
        allow(Rails.logger).to receive(:info)

        migrator.migrate(:up)

        expect(Rails.logger).to have_received(:info).with("Updated 0 ActionLog records from Decidim::ParticipatorySpacePrivateUser to Decidim::ParticipatorySpace::Member")
      end
    end

    context "when the table is empty" do
      it "does not raise an error" do
        expect { migrator.migrate(:up) }.not_to raise_error
      end

      it "logs that zero records were updated" do
        allow(Rails.logger).to receive(:info)

        migrator.migrate(:up)

        expect(Rails.logger).to have_received(:info).with("Updated 0 ActionLog records from Decidim::ParticipatorySpacePrivateUser to Decidim::ParticipatorySpace::Member")
      end
    end
  end

  describe "#down" do
    it "raises ActiveRecord::IrreversibleMigration" do
      expect { migrator.migrate(:down) }.to raise_error(ActiveRecord::IrreversibleMigration)
    end
  end
end
