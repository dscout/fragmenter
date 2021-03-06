module Fragmenter
  module Rails
    module Controller
      def show
        render json: fragmenter.as_json, status: 200
      end

      def update
        uploader = request_uploader

        if uploader.store
          render json: fragmenter.as_json, status: update_status(uploader)
        else
          render json: {
            message: 'Upload of part failed.', errors: uploader.errors
          }, status: 422
        end
      end

      def destroy
        fragmenter.clean!

        render nothing: true, status: 204
      end

      private

      def fragmenter
        resource.fragmenter
      end

      def validators
        [Fragmenter::Validators::ChecksumValidator]
      end

      def request_uploader
        Fragmenter::Services::Uploader.new(
          Fragmenter::Request.new(
            resource:   resource,
            fragmenter: fragmenter,
            body:       request.body,
            headers:    request.env
          ), validators
        )
      end

      def update_status(uploader)
        uploader.complete? ? 202 : 200
      end
    end
  end
end
