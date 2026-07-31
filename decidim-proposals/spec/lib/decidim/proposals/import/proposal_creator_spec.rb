# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::Import::ProposalCreator do
  subject { described_class.new(data, context) }

  let!(:moment) { Time.current }
  let(:data) do
    {
      :id => 1337,
      "id" => "101",
      :taxonomies => taxonomies,
      :scope => scope,
      :"title/en" => Faker::Lorem.sentence,
      :"body/en" => Faker::Lorem.paragraph(sentence_count: 3),
      :address => "#{Faker::Address.street_name}, #{Faker::Address.city}",
      :latitude => Faker::Address.latitude,
      :longitude => Faker::Address.longitude,
      :component => component,
      :published_at => moment
    }
  end
  let(:organization) { create(:organization, available_locales: [:en]) }
  let(:user) { create(:user, :confirmed, organization:) }
  let(:context) do
    {
      current_organization: organization,
      current_user: user,
      current_component: component,
      current_participatory_space: participatory_process
    }
  end
  let(:participatory_process) { create(:participatory_process, organization:) }
  let(:component) { create(:proposal_component, participatory_space: participatory_process) }
  let(:scope) { create(:scope, organization:) }
  let(:root_taxonomy) { create(:taxonomy, organization:) }
  let(:taxonomy1) { create(:taxonomy, parent: root_taxonomy, organization:) }
  let(:taxonomy2) { create(:taxonomy, parent: root_taxonomy, organization:) }
  let(:taxonomies) { { "ids" => [taxonomy1.id, taxonomy2.id] } }

  it "removes the IDs from the hash" do
    expect(subject.instance_variable_get(:@data)).not_to have_key(:id)
    expect(subject.instance_variable_get(:@data)).not_to have_key("id")
  end

  describe "#resource_klass" do
    it "returns the correct class" do
      expect(described_class.resource_klass).to be(Decidim::Proposals::Proposal)
    end
  end

  describe ".batch_notifier_klass" do
    it "returns the batch notifier class" do
      expect(described_class.batch_notifier_klass).to eq(Decidim::Proposals::Import::BatchNotifier)
    end
  end

  describe "#resource_attributes" do
    it "returns the attributes hash" do
      expect(subject.resource_attributes).to eq(
        "title/en": data[:"title/en"],
        "body/en": data[:"body/en"],
        taxonomies: data[:taxonomies],
        scope: data[:scope],
        address: data[:address],
        latitude: data[:latitude],
        longitude: data[:longitude],
        component: data[:component],
        published_at: data[:published_at]
      )
    end
  end

  describe "#produce" do
    it "makes a new proposal" do
      record = subject.produce

      expect(record).to be_a(Decidim::Proposals::Proposal)
      expect(record.taxonomies).to contain_exactly(taxonomy1, taxonomy2)
      expect(record.scope).to eq(scope)
      expect(record.title["en"]).to eq(data[:"title/en"])
      expect(record.body["en"]).to eq(data[:"body/en"])
      expect(record.address).to eq(data[:address])
      expect(record.latitude).to eq(data[:latitude])
      expect(record.longitude).to eq(data[:longitude])
      expect(record.published_at).to be >= (moment)
    end

    context "when import data comes from flattened JSON" do
      let(:data) do
        {
          "id" => "101",
          :"taxonomies/ids" => [taxonomy1.id, taxonomy2.id],
          :"scope/id" => [scope.id],
          :"title/en" => Faker::Lorem.sentence,
          :"body/en" => Faker::Lorem.paragraph(sentence_count: 3),
          :address => nil,
          :latitude => nil,
          :longitude => nil
        }
      end

      it "parses taxonomy IDs from array values" do
        record = subject.produce

        expect(record.taxonomies).to contain_exactly(taxonomy1, taxonomy2)
      end

      it "parses scope ID from array values" do
        record = subject.produce

        expect(record.scope).to eq(scope)
      end

      it "parses taxonomy IDs from CSV strings" do
        data[:"taxonomies/ids"] = "#{taxonomy1.id},#{taxonomy2.id}"

        record = subject.produce

        expect(record.taxonomies).to contain_exactly(taxonomy1, taxonomy2)
      end

      it "does not fail when scope is missing" do
        data.delete(:"scope/id")
        record = subject.produce

        expect(record.scope).to be_nil
      end
    end
    it "sets the organization as author (official proposal)" do
      record = subject.produce

      expect(record.authors).to contain_exactly(organization)
      expect(record.official?).to be true
    end
  end

  describe "#finish!" do
    it "saves the proposal" do
      record = subject.produce
      subject.finish!

      expect(record.new_record?).to be(false)
    end

    it "publishes proposal notifications for followers" do
      record = subject.produce
      allow(Decidim::EventsManager).to receive(:publish)

      subject.finish!

      expect(Decidim::EventsManager).to have_received(:publish).with(
        event: "decidim.events.proposals.proposal_published",
        event_class: Decidim::Proposals::PublishProposalEvent,
        resource: record,
        followers: record.participatory_space.followers,
        extra: {
          participatory_space: true
        }
      )
    end

    it "creates admin log" do
      record = subject.produce

      expect { subject.finish! }.to change(Decidim::ActionLog, :count).by(1)
      expect(Decidim::ActionLog.last.user).to eq(user)
      expect(Decidim::ActionLog.last.resource).to eq(record)
      expect(Decidim::ActionLog.last.visibility).to eq("admin-only")
    end
  end

  describe "#finish_without_notify!" do
    it "saves proposal without publishing events" do
      record = subject.produce
      allow(Decidim::EventsManager).to receive(:publish)

      subject.finish_without_notify!

      expect(record.new_record?).to be(false)
      expect(Decidim::EventsManager).not_to have_received(:publish)
    end
  end
end
