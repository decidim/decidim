# frozen_string_literal: true

require "spec_helper"

require "./db/data/20260319145808_rename_send_to_members_in_newsletter"

describe RenameSendToMembersInNewsletter do
  let(:migrator) do
    described_class.new.tap do |m|
      m.verbose = false
    end
  end

  describe "#up" do
    let(:organization) { create(:organization) }

    context "when there are newsletters with send_to_private_members" do
      let!(:newsletter_with_old_key) do
        create(:newsletter, organization:, extended_data: { "send_to_private_members" => true, "subject" => { "en" => "Test" } })
      end

      let!(:newsletter_with_old_key_false) do
        create(:newsletter, organization:, extended_data: { "send_to_private_members" => false, "subject" => { "en" => "Test 2" } })
      end

      let!(:newsletter_with_new_key) do
        create(:newsletter, organization:, extended_data: { "send_to_members" => true, "subject" => { "en" => "Test 3" } })
      end

      let!(:newsletter_without_key) do
        create(:newsletter, organization:, extended_data: { "subject" => { "en" => "Test 4" } })
      end

      it "renames send_to_private_members to send_to_members" do
        migrator.migrate(:up)

        newsletter_with_old_key.reload
        expect(newsletter_with_old_key.extended_data).to have_key("send_to_members")
        expect(newsletter_with_old_key.extended_data).not_to have_key("send_to_private_members")
        expect(newsletter_with_old_key.extended_data["send_to_members"]).to be(true)

        newsletter_with_old_key_false.reload
        expect(newsletter_with_old_key_false.extended_data).to have_key("send_to_members")
        expect(newsletter_with_old_key_false.extended_data).not_to have_key("send_to_private_members")
        expect(newsletter_with_old_key_false.extended_data["send_to_members"]).to be(false)
      end

      it "does not affect newsletters that already have the new key" do
        migrator.migrate(:up)

        newsletter_with_new_key.reload
        expect(newsletter_with_new_key.extended_data).to have_key("send_to_members")
        expect(newsletter_with_new_key.extended_data["send_to_members"]).to be(true)
      end

      it "does not affect newsletters without the old key" do
        migrator.migrate(:up)

        newsletter_without_key.reload
        expect(newsletter_without_key.extended_data).not_to have_key("send_to_private_members")
        expect(newsletter_without_key.extended_data).not_to have_key("send_to_members")
      end
    end

    context "when there are no newsletters with the old key" do
      let!(:newsletter) do
        create(:newsletter, organization:, extended_data: { "send_to_members" => true })
      end

      it "does not raise an error" do
        expect { migrator.migrate(:up) }.not_to raise_error
      end
    end

    context "when there are no newsletters at all" do
      it "does not raise an error" do
        expect { migrator.migrate(:up) }.not_to raise_error
      end
    end

    context "when extended_data is nil" do
      let!(:newsletter_without_extended_data) do
        create(:newsletter, organization:, extended_data: nil)
      end

      it "does not raise an error" do
        expect { migrator.migrate(:up) }.not_to raise_error
      end
    end
  end

  describe "#down" do
    let(:organization) { create(:organization) }

    context "when there are newsletters with send_to_members" do
      let!(:newsletter_with_new_key) do
        create(:newsletter, organization:, extended_data: { "send_to_members" => true })
      end

      it "renames send_to_members back to send_to_private_members" do
        migrator.migrate(:down)

        newsletter_with_new_key.reload
        expect(newsletter_with_new_key.extended_data).to have_key("send_to_private_members")
        expect(newsletter_with_new_key.extended_data).not_to have_key("send_to_members")
        expect(newsletter_with_new_key.extended_data["send_to_private_members"]).to be(true)
      end
    end
  end
end
