require 'fragmenter/rails/model'

Resource = Struct.new(:id) do
  include Fragmenter::Rails::Model

  def rebuild_fragments
    fragmenter.rebuild && fragmenter.clean!
  end
end
