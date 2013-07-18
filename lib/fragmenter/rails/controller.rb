module Fragmenter
  module Rails
    module Controller
      def show
        render json: fragmenter.as_json
      end

      def update
        if uploader.store
          render json: fragmenter.as_json, status: update_status
        else
          render json: {
            message: 'Upload of part failed.', errors: uploader.errors
          }, status: :unprocessable_entity
        end
      end

      def destroy
        fragmenter.clean!

        render nothing: true, status: :no_content
      end

      private

      def fragmenter
        resource.fragmenter
      end

      def validators
        [Fragmenter::Validators::ChecksumValidator]
      end

      def uploader
        @uploader ||= Fragmenter::Services::Uploader.new(
          Fragmenter::Request.new(
            resource:   resource,
            fragmenter: fragmenter,
            body:       request.body,
            headers:    request.headers
          ), validators
        )
      end

      def update_status
        uploader.complete? ? :accepted : :ok
      end
    end
  end
end
