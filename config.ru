require 'dotenv'
Dotenv.load

require './app.rb'

use Rack::Deflater
use Sites::Middleware

Precious::App.set(:gollum_path, '/')
Precious::App.set(:wiki_options, {live_preview: false, allow_uploads: true})
run Precious::App
