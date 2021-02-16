# frozen_string_literal: true

shared_context "when mocking the bulletin board in the browser" do
  before do
    proxy.stub("http://bulletin-board.lvh.me:8000/api", method: "options").and_return(
      headers: { "Access-Control-Allow-Origin" => "*",
                 "Access-Control-Allow-Headers" => "content-type" },
      text: ""
    )
  end
end
