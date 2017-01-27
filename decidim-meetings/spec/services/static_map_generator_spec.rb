require "spec_helper"

module Decidim
  module Meetings
    describe StaticMapGenerator do
      let(:meeting) { create(:meeting) }
      let(:options) do
        {
          zoom: 10,
          width: 200,
          height: 200
        }
      end
      let(:body) { "1234" }
      subject { described_class.new(meeting, options) }

      before do
        Decidim.geocoder = {
          here_app_id: '1234',
          here_app_code: '5678'
        }

        stub_request(:get, Regexp.new(StaticMapGenerator::BASE_HOST)).to_return(body: body)
      end

      describe "#data" do
        it "returns the request body" do
          expect(subject.data).to eq(body)
        end
      end
    end
  end
end
