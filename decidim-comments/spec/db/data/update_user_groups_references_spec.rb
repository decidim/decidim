# frozen_string_literal: true

require "spec_helper"
require "./db/data/20251117070404_update_user_groups_references"

describe UpdateUserGroupsReferences do
  let(:migrator) do
    described_class.new.tap do |m|
      m.verbose = false
    end
  end

  describe "#up" do
    let!(:comment) { create(:comment, body:) }

    describe "with a normal body" do
      let(:body) { { "en" => "This is a normal body" } }
      let(:result) { { "en" => "This is a normal body" } }

      it "does not do anything" do
        expect(comment.reload.body).to eq(body)
        migrator.migrate(:up)
        expect(comment.reload.body).to eq(result)
      end
    end

    describe "with a User reference in the body" do
      let(:body) { { "en" => "This is a body mentioning gid://decidim-test/Decidim::User/9" } }
      let(:result) { { "en" => "This is a body mentioning gid://decidim-test/Decidim::User/9" } }

      it "does not do anything" do
        expect(comment.reload.body).to eq(body)
        migrator.migrate(:up)
        expect(comment.reload.body).to eq(result)
      end
    end

    describe "with a UserGroup reference in the body" do
      let(:body) { { "en" => "This is a body mentioning gid://decidim-development-app/Decidim::UserGroup/5" } }
      let(:result) { { "en" => "This is a body mentioning gid://decidim-development-app/Decidim::User/5" } }

      it "changes the reference to User" do
        expect(comment.reload.body).to eq(body)
        migrator.migrate(:up)
        expect(comment.reload.body).to eq(result)
      end
    end

    describe "with a UserGroup reference in the body and machine translation enabled" do
      let(:body) do
        {
          "en" => "This is a body mentioning gid://decidim-development-app/Decidim::UserGroup/5",
          "machine_translations" => {
            "es" => "Este es el cuerpo mencionando gid://decidim-development-app/Decidim::UserGroup/5"
          }
        }
      end
      let(:result) do
        {
          "en" => "This is a body mentioning gid://decidim-development-app/Decidim::User/5",
          "machine_translations" => {
            "es" => "Este es el cuerpo mencionando gid://decidim-development-app/Decidim::User/5"
          }
        }
      end

      it "changes the reference to User" do
        expect(comment.reload.body).to eq(body)
        migrator.migrate(:up)
        expect(comment.reload.body).to eq(result)
      end
    end
  end

  describe "#down" do
    it "raises IrreversibleMigration exception" do
      expect { migrator.migrate(:down) }.to raise_error(ActiveRecord::IrreversibleMigration)
    end
  end
end
