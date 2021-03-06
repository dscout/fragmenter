require 'spec_helper'
require 'fragmenter/rails/controller'

describe Fragmenter::Rails::Controller do
  UploadController = Struct.new(:resource) do
    include Fragmenter::Rails::Controller
  end

  resource_class = Struct.new(:id) do
    def fragmenter
      @fragmenter ||= Fragmenter::Wrapper.new(self)
    end
  end

  describe '#show' do
    it 'renders the JSON representation of the associated fragmenter' do
      resource   = resource_class.new(100)
      controller = UploadController.new(resource)

      controller.stub(:render)

      controller.show

      expect(controller).to have_received(:render).with(
        json: { 'fragments' => [] },
        status: 200
      )
    end
  end

  describe '#destroy' do
    it 'commands the fragmenter to clean' do
      resource   = resource_class.new(100)
      controller = UploadController.new(resource)

      controller.stub(:render)
      resource.fragmenter.stub(:clean!)

      controller.destroy

      expect(resource.fragmenter).to have_received(:clean!)
      expect(controller).to have_received(:render).with(
        nothing: true,
        status: 204
      )
    end
  end

  describe '#update' do
    it 'stores the request body' do
      resource   = resource_class.new(100)
      controller = UploadController.new(resource)
      uploader   = double(:uploader, store: true, complete?: false)

      controller.stub(render: true, request_uploader: uploader)

      controller.update

      expect(uploader).to have_received(:store)
      expect(controller).to have_received(:render).with(
        json: { 'fragments' => [] },
        status: 200
      )
    end

    it 'renders error messages if storage fails' do
      resource   = resource_class.new(100)
      controller = UploadController.new(resource)
      uploader   = double(:uploader, store: false, errors: [], complete?: false)

      controller.stub(render: true, request_uploader: uploader)

      controller.update

      expect(controller).to have_received(:render).with(
        json: {
          message: 'Upload of part failed.',
          errors:  []
        },
        status: 422
      )
    end
  end
end
