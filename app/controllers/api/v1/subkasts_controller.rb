module Api
  module V1
    class SubkastsController < BaseController
      def index
        expose(Subkast.paginate(page: params[:page]))
      end
    end
  end
end
