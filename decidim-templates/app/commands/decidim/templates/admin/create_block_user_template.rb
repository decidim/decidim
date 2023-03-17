# frozen_string_literal: true

module Decidim
  module Templates
    module Admin
      class CreateBlockUserTemplate < CreateTemplate
        protected

        def target
          :user_block
        end
      end
    end
  end
end
