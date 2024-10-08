# frozen_string_literal: true

require "spec_helper"

module ActiveStorage
  describe DiskController do
    describe "GET #show" do
      include Rails.application.routes.url_helpers
      before do
        ActiveStorage::Current.url_options = { host: "example.com", protocol: "http" }
      end

      it "correctly reports the uploaded metadata" do
        filename = "odt_file_reported_as.pdf"
        io = StringIO.new(Decidim::Dev.asset(filename))
        blob = ActiveStorage::Blob.create_and_upload! io:, filename:, content_type: "application/pdf", identify: true, service_name: nil, record: nil

        params = Rails.application.routes.recognize_path(blob.url).except(:controller, :action)

        get(:show, params:)

        # The response is a stream, and using the have_http_status matcher will raise a NoMethodError
        # ( undefined method `body' for #<Rack::Files::Iterator ... )
        expect(response.status).to eq(200) # rubocop:disable RSpecRails/HaveHttpStatus
        expect(response.headers["Content-Disposition"]).to eq("inline; filename=\"odt_file_reported_as.pdf\"; filename*=UTF-8''odt_file_reported_as.pdf")
        expect(response.headers["Content-Type"]).to eq("application/pdf")
      end
    end
  end
end
