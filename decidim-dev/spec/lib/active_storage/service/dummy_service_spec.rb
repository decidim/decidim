# frozen_string_literal: true

require "spec_helper"
require "active_storage/service/dummy_service"

describe ActiveStorage::Service::DummyService do
  subject(:service) { described_class.new(host:, public:) }

  let(:host) { "https://storage.lvh.me" }
  let(:public) { true }

  describe "#upload" do
    let(:data) { "a" * 10_000 }
    let(:key) { "key" }

    it "allows uploading same key only once" do
      errors = 0
      threads = 100.times.map do
        Thread.new do
          io = StringIO.new(data)
          begin
            service.upload(key, io)
          rescue ActiveStorage::IntegrityError
            errors += 1
          end
        end
      end
      threads.each(&:join)

      expect(errors).to be(99)
      expect(service.download(key)).to eq(data)
    end
  end

  describe "#download" do
    let(:buffer) { StringIO.new }
    let(:key) { "key" }

    before do
      chars = ("a".."z").to_a
      1_000_000.times do
        buffer.write(chars.sample)
      end
      buffer.rewind
      service.upload(key, buffer)
    end

    it "allows concurrent reading without changing the positions of other threads" do
      data = buffer.read
      equalities = []
      threads = 100.times.map do |n|
        Thread.new do
          received = service.download(key)
          equalities[n] = (received == data)
        end
      end
      threads.each(&:join)

      expect(equalities.uniq).to eq([true])
    end
  end

  describe "#download_chunk" do
    let(:buffer) { StringIO.new }
    let(:key) { "key" }

    before do
      chars = ("a".."z").to_a
      1_000_000.times do
        buffer.write(chars.sample)
      end
      buffer.rewind
      service.upload(key, buffer)
    end

    it "allows concurrent reading without changing the positions of other threads" do
      data = buffer.read
      equalities = []
      threads = 100.times.map do |n|
        start = rand(data.size - 100)
        range = (start..(start + 100))
        Thread.new do
          received = service.download_chunk(key, range)
          equalities[n] = (received == data[range])
        end
      end
      threads.each(&:join)

      expect(equalities.uniq).to eq([true])
    end
  end
end
