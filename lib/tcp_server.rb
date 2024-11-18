require 'socket'

class HTTPServer

    def initialize(port)
        @port = port
    end

    def start
        server = TCPServer.new(@port)
        puts "Listening on #{@port}"
        #router = Router.new
        #router.add_route...

        while session = server.accept
            data = ""
            while line = session.gets and line !~ /^\s*$/
                data += line
            end
            puts "RECEIVED REQUEST"
            puts "-" * 40
            puts data
            puts "-" * 40 

            #request = Request.new(data)
            #router.match_route(request)
            #Sen kolla om resursen (filen finns)


            # Nedanstående bör göras i er Response-klass
            html = "
<!DOCTYPE html>
<html lang='sv'>
<head>
<meta charset='UTF-8'>
<meta name='viewport' content='width=device-width, initial-scale=1.0'>
<title>Leos Sinatra Clone</title>
<style>
    body {
        font-family: Arial, sans-serif;
        background-color: #f0f0f0;
        color: #333;
        padding: 20px;
    }
    header {
        background-color: #ADD8E6;
        color: white;
        padding: 10px 0;
        text-align: center;
    }
    h1 {
        margin: 0;
        font-size: 2.5em;
    }
    .container {
        max-width: 800px;
        margin: 0 auto;
        background-color: white;
        padding: 20px;
        box-shadow: 0 0 10px rgba(0,0,0,0.1);
        border-radius: 8px;
    }
    p {
        line-height: 1.6;
    }
    .btn {
        display: inline-block;
        padding: 10px 20px;
        margin-top: 20px;
        background-color: #ADD8E6;
        color: white;
        text-decoration: none;
        border-radius: 5px;
    }
    .btn:hover {
        background-color: #46a7c6;
    }
    footer {
        text-align: center;
        padding: 10px 0;
        margin-top: 20px;
        color: #777;
    }
</style>
</head>
<body>
    <header>
        <h1>Välkommen till min Sinatra-klon!</h1>
    </header>
    <div class='container'>
        <h2>Hej där, Leo!</h2>
        <p>
            Det var en gång...
        </p>
        <h3>Funktioner</h3>
        <ul>
            <li>Enkel TCP-server byggd med Ruby</li>
            <li>Kan hantera HTTP GET-förfrågningar</li>
            <li>En grundläggande router och svarsklass (på gång!)</li>
        </ul>
        <p>
            Vill du se mer? Klicka på knappen nedan för att utforska vidare!
        </p>
        <a href='#' class='btn'>Läs mer</a>
    </div>
    <footer>
        &copy; 2024 Vilees HTTP Server
    </footer>
</body>
</html>
"
            session.print "HTTP/1.1 200\r\n"
            session.print "Content-Type: text/html\r\n"
            session.print "\r\n"
            session.print html
            session.close
        end
    end
end

server = HTTPServer.new(4567)
server.start