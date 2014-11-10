module Api
  class ApiController < RocketPants::Base
    include Devise::Controllers::Helpers

    def authenticate!
      error! :unauthenticated if api_current_user.nil?
    end

    def api_current_user
      current_user
    end
  end
end
