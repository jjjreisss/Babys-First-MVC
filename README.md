# Baby's First MVC

Backend application framework inspired by Rails, includes ActiveRecord Lite, a lightweight version of ActiveRecord and an object-relational mapper (ORM) between Ruby and SQL.

The purpose of this project is to demonstrate understanding of MVC, the Ruby on Rails framework, and ActiveRecord-assisted SQL commands.

##Server Infrastructure

Baby's First MVC is run on a Rack, located in /bin/router_server.rb, utilizing the Rack API to handle HTTP requests and responses.

Two custom middlewares are implemented: Stack Tracer and Static Assets.

##Stack Tracer

The Stack Tracer is able to capture exceptions raised by all other middleware and the application itself. It raises a custom 500 error page with a code snippet from the error source and the stack trace.

##Static Assets

Static assets contained in /public/ file path are made available when a GET request is submitted with /public/ after the hostname.

The Static Asset middleware matches the /public/ path and responds with the corresponding static asset, such as images and HTML files.

For example a server running locally would be able to access the sample image in localhost:3000/public/paper_mario.jpg

##Architecture and MVC

Baby's First MVC includes a custom router, controller base, and model base.

###Router

Through meta-programming, the router dynamically creates a route for each controller action. When passed a request, the router runs the responsible route to call on the corresponding controller action.

###Controller Base

The Controller Base functions similarly to the ActionController::Base in Ruby on Rails. It is the super class that provides the standard controller methods (render, redirect_to, session, and flash). User-defined controller actions are invoked by the corresponding route.

###Model Base

This serves as the base class for user-generated models. It is a lightweight version of the ActiveRecord::Base class in Ruby on Rails, used for ORM between Ruby and SQL.

Included methods are the standard queries:

#all
#find
#insert
#update
#save
In addition, inheriting from SQLObject grants the #where method from the Searchable module, to dynamically query from the SQL RDBMS.

The Associatable module is extended as well, to provide the three standard methods for model associations:

belongs_to
has_many
has_one_through
Additional Features

##Session

The client session is stored as a cookie through the Rack cookie-setter and getter methods. This allows the Rails app to authenticate user session upon receiving the HTTP request.

##Flash

The Flash class is used to display notifications to the client, whether immediately or stored to be displayed after a redirect.

Flash#now is used for displaying notifications upon rendering a view. Meanwhile, the standard flash stores any object as a cookie in the response. This allows data (e.g. message strings) to persist through a redirect.
