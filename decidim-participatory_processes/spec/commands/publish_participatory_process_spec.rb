# frozen_string_literal: true

require "spec_helper"

describe "Participatory Process can be published", type: :system do
  it_behaves_like "Publicable space", :participatory_process
end
