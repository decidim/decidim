# frozen_string_literal: true

require "spec_helper"

require "./db/data/20260616144141_rename_answers_to_responses"

describe RenameAnswersToResponses do
  let(:migrator) do
    described_class.new.tap do |m|
      m.verbose = false
    end
  end

  let(:organization) { create(:organization) }
  let!(:participatory_process) { create(:participatory_process, organization:) }
  let(:user) { create(:user, organization:) }
  let!(:questionnaire) { create(:questionnaire, questionnaire_for: participatory_process) }
  let(:response) { create(:response, questionnaire:) }
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
                                      resource_type: "Decidim::Forms::Questionnaire",
                                      resource_id: questionnaire.id,
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
                                      resource_type: "Decidim::Forms::Answer",
                                      resource_id: response.id,
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
    expect(Decidim::ActionLog.where(resource_type: "Decidim::Forms::Questionnaire").first.resource).to eq(questionnaire)
    expect(Decidim::ActionLog.where(resource_type: "Decidim::Forms::Response").first).to be_nil

    migrator.migrate(:up)
    expect(Decidim::ActionLog.where(resource_type: "Decidim::Forms::Questionnaire").first.resource).to eq(questionnaire)
    expect(Decidim::ActionLog.where(resource_type: "Decidim::Forms::Response").first.resource).to eq(response)

    migrator.migrate(:down)
    expect(Decidim::ActionLog.where(resource_type: "Decidim::Forms::Questionnaire").first.resource).to eq(questionnaire)
    expect(Decidim::ActionLog.where(resource_type: "Decidim::Forms::Response").first).to be_nil
  end

  class Version < ApplicationRecord
    self.table_name = "versions"
  end

  it "updates properly the paper trail versions" do
    Version.create!(
      item_type: "Decidim::Forms::Answer",
      item_id: response.id,
      event: "update",
      whodunnit: user.id.to_s,
      object: "{}",
      object_changes: "{}",
      created_at: Time.current
    )

    expect(Version.where(item_type: "Decidim::Forms::Response").first).to be_nil

    migrator.migrate(:up)
    expect(Version.where(item_type: "Decidim::Forms::Response").first.item_id).to eq(response.id)

    migrator.migrate(:down)
    expect(Version.where(item_type: "Decidim::Forms::Response").first).to be_nil
  end

  context "when having attachments" do
    let!(:response) { create(:response, :with_attachments, questionnaire:) }
    let!(:other_attachment) { create(:attachment, attached_to: participatory_process) }

    it "updates properly the attachments" do
      # rubocop:disable Rails/SkipsModelValidations
      Decidim::Attachment.where(attached_to_type: "Decidim::Forms::Response").update_all(attached_to_type: "Decidim::Forms::Answer")
      # rubocop:enable Rails/SkipsModelValidations

      expect(Decidim::Attachment.where(attached_to_type: "Decidim::Forms::Answer").first).to be_present

      migrator.migrate(:up)
      expect(Decidim::Attachment.where(attached_to_type: "Decidim::Forms::Response").first).to eq(response.attachments.first)
      expect(Decidim::Attachment.where(attached_to_type: "Decidim::ParticipatoryProcess").first).to eq(other_attachment)

      migrator.migrate(:down)
      expect(Decidim::Attachment.where(attached_to_type: "Decidim::Forms::Answer").first).to be_present
      expect(Decidim::Attachment.where(attached_to_type: "Decidim::ParticipatoryProcess").first).to eq(other_attachment)
    end
  end
end
