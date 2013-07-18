require 'spec_helper'
require 'fragmenter/rails/model'

describe Fragmenter::Rails::Model do
  let(:model) do
    double(:model).extend(Fragmenter::Rails::Model)
  end

  it 'adds a fragmenter wrapper around the underlying model' do
    expect(model).to respond_to(:fragmenter)
    expect(model.fragmenter).to be_instance_of(Fragmenter::Wrapper)
  end

  it 'adds an abstract rebuild_fragments method for compatibility' do
    expect(model).to respond_to(:rebuild_fragments)
    expect { model.rebuild_fragments }.to raise_error(Fragmenter::AbstractMethodError)
  end
end
