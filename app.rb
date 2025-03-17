require_relative "lib/httpserver"
require_relative "lib/router"
require_relative "lib/view_renderer"

r = Router.new

# Definiera rutter
r.add_route(:get, '/') { ViewRenderer.render('index') }
r.add_route(:get, '/logged_in') { ViewRenderer.render('logged_in') }
r.add_route(:get, '/about') { ViewRenderer.render('about') }
r.add_route(:get, '/login') { ViewRenderer.render('login') }

r.add_route(:get, '/add/:num1/:num2') do |request|
  num1 = request.params[:num1].to_i
  num2 = request.params[:num2].to_i
  result = num1 + num2
  "<h1>Result: #{num1} + #{num2} = #{result}</h1><a href='/'>Go back to Home</a>"
end

r.add_route(:get, '/users/:id') do |request|
  user_id = request.params[:id]
  next_id = user_id.to_i + 1
  "<h1>User: #{user_id}</h1>
  <a href='/users/#{next_id}'>Next User (+1)</a>
  <a href='/'>Go back to Home</a>"
end

r.add_route(:post, '/submit') do |request|
  "<h1>Post request received! <a href='/'>Go back to Home</a></h1>"
end

# Starta HTTP-servern
server = HTTPServer.new(4567, r)
server.start
