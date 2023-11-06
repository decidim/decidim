# frozen_string_literal: true

require "spec_helper"

describe "Participatory Process can be unpublished", type: :system do
  it_behaves_like "Unpublicable space", :participatory_process
end
