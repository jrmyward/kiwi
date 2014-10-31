module Api
  module V1
    class SubkastsController < BaseController
      def index
        collection = Subkast.paginate(page: params[:page])

        expose(collection, only: [:code, :name, :url])
      end
    end
  end
end
