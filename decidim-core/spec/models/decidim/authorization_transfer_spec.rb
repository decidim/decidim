# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe AuthorizationTransfer do
    subject { transfer }

    let(:transfer) { build(:authorization_transfer, organization: organization, user: user, source_user: source_user, authorization: authorization) }

    let(:organization) { create(:organization) }
    let(:user) { create(:user, :confirmed, organization: organization) }
    let(:source_user) { create(:user, :confirmed, :deleted, organization: organization) }
    let(:authorization) do
      create(
        :authorization,
        :granted,
        user: source_user || create(:user, :confirmed, :deleted, organization: organization),
        unique_id: "12345678X"
      )
    end

    shared_context "with local block registry" do
      let(:registry) { Decidim::BlockRegistry.new }

      before do
        allow(described_class).to receive(:registry).and_return(registry)
      end
    end

    shared_context "with transfers disabled" do
      before { described_class.disable! }

      after { described_class.enable! }
    end

    it { is_expected.to be_valid }

    describe "validations" do
      context "without authorization" do
        let(:authorization) { nil }

        it { is_expected.not_to be_valid }
      end

      context "without user" do
        let(:user) { nil }

        it { is_expected.not_to be_valid }
      end

      context "without source user" do
        let(:source_user) { nil }

        it { is_expected.not_to be_valid }
      end
    end

    describe ".enabled?" do
      subject { described_class.enabled? }

      it { is_expected.to be(true) }

      context "when disabled" do
        include_context "with transfers disabled"

        it { is_expected.to be(false) }
      end
    end

    describe ".enable!" do
      include_context "with transfers disabled"

      subject { described_class.enable! }

      before { subject }

      it { is_expected.to be(true) }

      it "changes the enabled state of the class" do
        expect(described_class.enabled?).to be(true)
      end
    end

    describe ".disable!" do
      subject { described_class.disable! }

      # Make sure the method is called before the tests
      before { subject }

      after { described_class.enable! }

      it { is_expected.to be(false) }

      it "changes the enabled state of the class" do
        expect(described_class.enabled?).to be(false)
      end
    end

    describe ".perform!" do
      subject { described_class.perform!(authorization, authorization_handler) }

      let(:authorization_handler) do
        DummyAuthorizationHandler.from_params(
          document_number: authorization.unique_id,
          postal_code: "08001",
          user: user
        )
      end
      let(:component) { create(:component, manifest_name: "dummy", organization: organization) }
      let!(:dummy_resources) { create_list(:dummy_resource, 3, author: source_user, component: component) }
      let!(:coauthorable_dummy_resources) { create_list(:coauthorable_dummy_resource, 5, authors_list: [source_user], component: component) }

      include_context "with local block registry"

      before do
        registry.register(:dummy) do |tr|
          tr.move_records(Decidim::DummyResources::DummyResource, :decidim_author_id)
          tr.move_records(Decidim::Coauthorship, :decidim_author_id)
        end
      end

      context "when the functionality is enabled" do
        # Initiate the transfer
        before { subject }

        it "performs the transfer correctly and calls the registerd handlers" do
          expect(subject.records.count).to eq(8)
          expect(Decidim::DummyResources::DummyResource.where(decidim_author_id: user.id).order(:id)).to eq(
            dummy_resources.sort_by!(&:id)
          )
          expect(Decidim::Coauthorship.where(decidim_author_id: user.id).order(:id)).to eq(
            coauthorable_dummy_resources.map(&:coauthorships).reduce([], :+).sort_by!(&:id)
          )
          expect(Decidim::DummyResources::DummyResource.where(decidim_author_id: source_user.id).count).to be(0)
          expect(Decidim::Coauthorship.where(decidim_author_id: source_user.id).count).to be(0)

          # Check that authorization is correctly transferred and metadata is
          # updated
          expect(authorization.user).to be(user)
          expect(authorization.granted?).to be(true)
          expect(authorization.metadata["postal_code"]).to eq("08001")
        end

        context "with a pending authorization" do
          let(:authorization) { create(:authorization, :pending, user: source_user, unique_id: "12345678X") }

          it "grants the authorization during the transfer" do
            expect(authorization.granted?).to be(true)
          end
        end
      end

      context "when the functionality is disabled" do
        include_context "with transfers disabled"

        it "raises a DisabledError" do
          expect { subject }.to raise_error(Decidim::AuthorizationTransfer::DisabledError)
        end
      end
    end

    describe "#readonly?" do
      subject { transfer.readonly? }

      it "returns true for a persisted record" do
        transfer.save!
        expect(subject).to be(true)
      end

      it "returns false for a new record" do
        expect(subject).to be(false)
      end
    end

    describe "#announce!" do
      subject { transfer.announce!(handler) }

      let(:foo) { double }
      let(:bar) { double }
      let(:handler) { double }

      include_context "with local block registry"

      it "calls the registered transfer handlers" do
        registry.register(:foo) { |tr| foo.transfer(tr) }
        registry.register(:bar) { |tr| bar.move(tr) }

        expect(foo).to receive(:transfer).with(transfer)
        expect(bar).to receive(:move).with(transfer)

        subject
      end

      it "allows access to the provided handler" do
        registry.register(:foo) do |tr|
          expect(tr.handler).to be(handler)
        end

        subject
      end

      context "when the functionality is disabled" do
        include_context "with transfers disabled"

        it "raises a DisabledError" do
          expect { subject }.to raise_error(Decidim::AuthorizationTransfer::DisabledError)
        end
      end
    end

    describe "#presenter" do
      subject { transfer.presenter }

      it "returns an authorization transfer presenter instance" do
        expect(subject).to be_a(Decidim::AuthorizationTransferPresenter)
      end
    end

    describe "#information" do
      subject { transfer.information }

      let(:component) { create(:component, manifest_name: "dummy", organization: organization) }
      let(:dummy_resources) { create_list(:dummy_resource, 3, author: user, component: component) }
      let(:coauthorable_dummy_resources) { create_list(:coauthorable_dummy_resource, 5, authors_list: [user], component: component) }

      let(:amendments) do
        dummy_resources.map do |amendable|
          create(:amendment, amendable: amendable, emendation: create(:dummy_resource, author: user, component: amendable.component))
        end.flatten
      end
      let(:endorsements) do
        dummy_resources.map { |endorsable| create(:endorsement, resource: endorsable, author: user) }.flatten
      end

      before do
        (dummy_resources + amendments + endorsements).each do |r|
          create(:authorization_transfer_record, transfer: transfer, resource: r)
        end
        coauthorable_dummy_resources.each do |r|
          r.coauthorships.each { |c| create(:authorization_transfer_record, transfer: transfer, resource: c) }
        end
      end

      it "returns information about the transferred records" do
        expect(subject).to eq(
          "Decidim::DummyResources::DummyResource" => {
            class: Decidim::DummyResources::DummyResource,
            count: dummy_resources.count + amendments.count
          },
          "Decidim::DummyResources::CoauthorableDummyResource" => {
            class: Decidim::DummyResources::CoauthorableDummyResource,
            count: coauthorable_dummy_resources.count
          },
          "Decidim::Endorsement" => {
            class: Decidim::Endorsement,
            count: endorsements.count
          }
        )
      end
    end

    describe "#move_records" do
      subject { transfer.move_records(Decidim::DummyResources::DummyResource, :decidim_author_id) }

      let(:component) { create(:component, manifest_name: "dummy", organization: organization) }
      let!(:dummy_resources) { create_list(:dummy_resource, 3, author: source_user, component: component) }

      before { transfer.save! }

      it "returns an array of authorization transfer records" do
        expect(subject).to be_a(Array)
        expect(subject.count).to be(3)
        expect(subject.first).to be_a(Decidim::AuthorizationTransferRecord)
      end

      it "updates the provided user column with the new user" do
        expect(subject.map(&:resource).sort_by!(&:id)).to eq(dummy_resources.sort_by!(&:id))
        expect(Decidim::DummyResources::DummyResource.where(decidim_author_id: user.id).count).to be(3)
      end
    end
  end
end
