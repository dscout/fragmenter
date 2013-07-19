require 'fragmenter'

class Uploads < Sinatra::Base
  include Fragmenter::Rails::Controller

  put '/' do
    show
  end
end

run Uploads
