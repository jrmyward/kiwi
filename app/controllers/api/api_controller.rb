module Api
  class ApiController < RocketPants::Base
    include Devise::Controllers::Helpers

    def api_current_user
      current_user
    end
  end
end
