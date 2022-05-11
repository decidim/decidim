module Cell
  module RailsExtensions
    # This modules overrides Cell::Testing#controller_for and provides Rails-specific logic.
    module Testing
      RAILS_8_0 = Gem::Version.new("8.0.0")
      
      def action_controller_test_request(controller_class)
        version = ::Rails.gem_version

        if version >= RAILS_5_1 && version < RAILS_8_0
          ::ActionController::TestRequest.create(controller_class)
        elsif version >= RAILS_5_0 && version < RAILS_5_1
          ::ActionController::TestRequest.create
        else
          ::ActionController::TestRequest.new
        end
      end
    end # Testing
  end
end

Cell::Testing.send(:include, Cell::RailsExtensions::Testing)

