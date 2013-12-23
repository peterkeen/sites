require 'dotenv'
Dotenv.load

require './app.rb'

use Sites::Middleware

Precious::App.set(:gollum_path, '/')
Precious::App.set(:wiki_options, {})
run Precious::App
