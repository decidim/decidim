# frozen_string_literal: true

require "spec_helper"

class ::TestPermissions < Object; end

module Decidim
  describe ParticipatorySpaceManifest do
    subject { described_class.new }

    describe "#context" do
      it "defines and caches contexts" do
        subject.context(:context1) do |context|
          context.layout = "layouts/context1"
        end

        subject.context(:context2) do |context|
          context.layout = "layouts/context2"
        end

        expect(subject.context(:context1).layout).to eq("layouts/context1")
        expect(subject.context(:context2).layout).to eq("layouts/context2")
      end
    end

    describe "permissions_class" do
      context "when permissions_class_name is set" do
        it "finds the permissions class from its name" do
          subject.permissions_class_name = "TestPermissions"

          expect(subject.permissions_class).to eq(TestPermissions)
        end
      end

      context "when permissions_class_name is not set" do
        it "returns nil" do
          subject.permissions_class_name = nil

          expect(subject.permissions_class).to be_nil
        end
      end

      context "when permissions_class_name is set to a class that does not exist" do
        it "raises an error" do
          subject.permissions_class_name = "FakeTestPermissions"

          expect { subject.permissions_class }.to raise_error(NameError)
        end
      end
    end

    describe "on_destroy_account" do
      let(:user) { Decidim::User.new }

      it "can be invoked even when is nil" do
        subject.invoke_on_destroy_account(user)
      end

      it "can be setted and invoked" do
        expected_name = "on account destroyed was invoked"
        subject.register_on_destroy_account do |user|
          user.name = expected_name
        end

        subject.invoke_on_destroy_account(user)
        expect(user.name).to eq(expected_name)
      end
    end
  end
end
