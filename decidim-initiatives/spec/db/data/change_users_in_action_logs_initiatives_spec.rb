# frozen_string_literal: true

require "spec_helper"

require "./db/data/20260208135004_change_users_in_action_logs_initiatives"

describe ChangeUsersInActionLogsInitiatives do
  let(:migrator) do
    described_class.new.tap do |m|
      m.verbose = false
    end
  end

  describe "#up" do
    let(:organization) { create(:organization) }
    let(:user) { create(:user, organization:) }
    let(:group) { create(:user, organization:, extended_data: { group: true }) }
    let(:admin) { create(:user, :admin, :confirmed, organization:) }
    let!(:initiative1) { create(:initiative, organization:, author: group) }
    let!(:initiative2) { create(:initiative, organization:, author: group) }
    let!(:initiative3) { create(:initiative, organization:, author: user) }
    let!(:initiative4) { create(:initiative, organization:, author: admin) }

    let!(:action_logs_with_other_types) do
      create_list(:action_log, 2, resource: create(:dummy_resource, organization:))
    end
    let!(:action_logs_with_old_type) do
      # rubocop:disable Rails/SkipsModelValidations
      Decidim::ActionLog.insert_all([
                                      {
                                        decidim_organization_id: organization.id,
                                        user_id: user.id,
                                        user_type: "Decidim::User",
                                        resource_type: "Decidim::Initiative",
                                        resource_id: initiative1.id,
                                        action: "create",
                                        visibility: "public-only",
                                        extra: {
                                          "user" => {
                                            "ip" => "127.0.0.1",
                                            "name" => "Dummy user",
                                            "nickname" => "dummy"
                                          },
                                          "resource" => {},
                                          "component" => {},
                                          "participatory_space" => {}
                                        },
                                        created_at: Time.current,
                                        updated_at: Time.current
                                      },
                                      {
                                        decidim_organization_id: organization.id,
                                        user_id: user.id,
                                        user_type: "Decidim::User",
                                        resource_type: "Decidim::Initiative",
                                        resource_id: initiative2.id,
                                        action: "create",
                                        visibility: "public-only",
                                        extra: {
                                          "user" => {
                                            "ip" => "127.0.0.1",
                                            "name" => "Dummy user",
                                            "nickname" => "dummy"
                                          },
                                          "resource" => {},
                                          "component" => {},
                                          "participatory_space" => {}
                                        },
                                        created_at: Time.current,
                                        updated_at: Time.current
                                      },
                                      {
                                        decidim_organization_id: organization.id,
                                        user_id: user.id,
                                        user_type: "Decidim::User",
                                        resource_type: "Decidim::Initiative",
                                        resource_id: initiative3.id,
                                        action: "create",
                                        visibility: "public-only",
                                        extra: {
                                          "user" => {
                                            "ip" => "127.0.0.1",
                                            "name" => "Dummy user",
                                            "nickname" => "dummy"
                                          },
                                          "resource" => {},
                                          "component" => {},
                                          "participatory_space" => {}
                                        },
                                        created_at: Time.current,
                                        updated_at: Time.current
                                      },
                                      {
                                        decidim_organization_id: organization.id,
                                        user_id: admin.id,
                                        user_type: "Decidim::User",
                                        resource_type: "Decidim::Initiative",
                                        resource_id: initiative4.id,
                                        action: "create",
                                        visibility: "public-only",
                                        extra: {
                                          "user" => {
                                            "ip" => "127.0.0.1",
                                            "name" => "Dummy user",
                                            "nickname" => "dummy"
                                          },
                                          "resource" => {},
                                          "component" => {},
                                          "participatory_space" => {}
                                        },
                                        created_at: Time.current,
                                        updated_at: Time.current
                                      },
                                      {
                                        decidim_organization_id: organization.id,
                                        user_id: admin.id,
                                        user_type: "Decidim::User",
                                        resource_type: "Decidim::Initiative",
                                        resource_id: 999_999,
                                        action: "create",
                                        visibility: "public-only",
                                        extra: {
                                          "user" => {
                                            "ip" => "127.0.0.1",
                                            "name" => "Dummy user",
                                            "nickname" => "dummy"
                                          },
                                          "resource" => {},
                                          "component" => {},
                                          "participatory_space" => {}
                                        },
                                        created_at: Time.current,
                                        updated_at: Time.current
                                      }
                                    ])
      # rubocop:enable Rails/SkipsModelValidations
    end

    it "updates properly the action logs" do
      expect(Decidim::ActionLog.where(resource: initiative4).first.user).to eq(admin)
      expect(Decidim::ActionLog.where(resource: initiative3).first.user).to eq(user)
      expect(Decidim::ActionLog.where(resource: initiative2).first.user).to eq(user)
      expect(Decidim::ActionLog.where(resource: initiative1).first.user).to eq(user)
      migrator.migrate(:up)
      expect(Decidim::ActionLog.where(resource: initiative4).first.user).to eq(admin)
      expect(Decidim::ActionLog.where(resource: initiative3).first.user).to eq(user)
      expect(Decidim::ActionLog.where(resource: initiative2).first.user).to eq(group)
      expect(Decidim::ActionLog.where(resource: initiative1).first.user).to eq(group)
    end

    context "when the table is empty" do
      let!(:action_logs_with_old_type) { [] }

      it "does not raise an error" do
        expect { migrator.migrate(:up) }.not_to raise_error
      end
    end
  end
end
