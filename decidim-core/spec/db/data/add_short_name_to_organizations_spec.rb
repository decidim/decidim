# frozen_string_literal: true

require "spec_helper"
require "./db/data/20251125144141_add_short_name_to_organizations"

describe AddShortNameToOrganizations do
  let(:migrator) do
    described_class.new.tap do |m|
      m.verbose = false
    end
  end

  describe "#up" do
    describe "with a normal name" do
      let!(:organization) do
        org = create(:organization, name: { en: "MyOrganization" })
        org.update_column(:short_name, {})
        org
      end

      it "generates short_name from name" do
        expect(organization.reload.short_name).to eq({})
        migrator.migrate(:up)
        expect(organization.reload.short_name).to eq({ "en" => "MyOrganizati" })
      end
    end

    describe "with a name containing spaces" do
      let!(:organization) do
        org = create(:organization, name: { en: "My Organization" })
        org.update_column(:short_name, {})
        org
      end

      it "removes spaces and generates short_name" do
        expect(organization.reload.short_name).to eq({})
        migrator.migrate(:up)
        expect(organization.reload.short_name).to eq({ "en" => "MyOrganizati" })
      end
    end

    describe "with a short name without spaces" do
      let!(:organization) do
        org = create(:organization, name: { en: "Test" })
        org.update_column(:short_name, {})
        org
      end

      it "uses the name as short_name" do
        expect(organization.reload.short_name).to eq({})
        migrator.migrate(:up)
        expect(organization.reload.short_name).to eq({ "en" => "Test" })
      end
    end

    describe "with a name that results in less than 3 characters" do
      let!(:organization) do
        org = create(:organization, name: { en: "A B" })
        org.update_column(:short_name, {})
        org
      end

      it "does not set short_name" do
        expect(organization.reload.short_name).to eq({})
        migrator.migrate(:up)
        expect(organization.reload.short_name).to eq({})
      end
    end

    describe "with a long name" do
      let!(:organization) do
        org = create(:organization, name: { en: "Very Long Organization Name" })
        org.update_column(:short_name, {})
        org
      end

      it "truncates to 12 characters" do
        expect(organization.reload.short_name).to eq({})
        migrator.migrate(:up)
        expect(organization.reload.short_name).to eq({ "en" => "VeryLongOrga" })
      end
    end

    describe "with a blank name" do
      let!(:organization) do
        org = create(:organization, name: { en: "" })
        org.update_column(:short_name, {})
        org
      end

      it "does not set short_name" do
        expect(organization.reload.short_name).to eq({})
        migrator.migrate(:up)
        expect(organization.reload.short_name).to eq({})
      end
    end
  end

  describe "#down" do
    it "raises IrreversibleMigration exception" do
      expect { migrator.migrate(:down) }.to raise_error(ActiveRecord::IrreversibleMigration)
    end
  end
end
