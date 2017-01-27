require "spec_helper"

describe Decidim::Meetings::StaticMapGenerator do
  let(:meeting) { create(:meeting) }
  let(:options) do
    {
      zoom: 10,
      width: 200,
      height: 200
    }
  end
  subject { described_class.new(meeting, options) }

  describe "#uri" do
    it "returns the uri for the generated static map" do
      uri = subject.uri

      expect(uri.host).to eq(Decidim::Meetings::StaticMapGenerator::BASE_HOST)
      expect(uri.path).to eq(Decidim::Meetings::StaticMapGenerator::BASE_PATH)

      expect(uri.query).to match meeting.latitude.to_s
      expect(uri.query).to match meeting.longitude.to_s

      expect(uri.query).to match "z=#{options[:zoom]}"
      expect(uri.query).to match "w=#{options[:width]}"
      expect(uri.query).to match "h=#{options[:height]}"

      expect(uri.query).to match "app_id=#{Decidim.geocoder[:api_key].first}"
      expect(uri.query).to match "app_code=#{Decidim.geocoder[:api_key].last}"
    end
  end
end
