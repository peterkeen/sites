# Sites

*Build and deploy microsites in the time it takes to create a CNAME.*

Spin up unlimited git-backed [Gollum wiki sites](https://github.com/gollum/gollum) on demand using a simple web interface then edit them in-browser to make prebaked websites.

## Why?

Something that I've wanted for a very long time is a way to stand up new websites with little more than a CNAME and a few clicks. I've gone through a few rounds of trying to make that happen but nothing ever stuck.

GitHub's Pages are of course one of the best answers, but I'm sticking to my self-hosting, built-at-home guns.

With Sites you can now manage your own *GitHub Pages* Pages at home!

## What does it actually do?

Start up 'Sites' and you now have a simple web interface where you can make as many new Gollum git projects as you like with the click of a button!

Check out my blog post for more:
https://www.petekeen.net/simple-git-backed-microsites

## Installation

1. $ git clone https://github.com/peterkeen/sites.git
2. $ mv .env.example .env
3. $ bundle install

## Getting started

    $ rackup # then visit localhost:9292 (authentication per .env file)

## Making a new site

1. Login
2. In the address bar type in the path for the project you want to create eg. localhost:9292/yournewsite
3. You should be directed back to the home page and there should now be a button there [create yournewsite]. Press the newly created button
4. Your site is now live (the github repo for the new site has been saved in a new folder matching your SITES_BASE_PATH name).
eg. /sites/localhost/yournewsite.git

## Edit your site

- From the main page click the site and this will bring up the Gollum wiki editing interface. 
- Edit pages on the site like a wiki. 
- Thanks to Gollum saved entries become commits in the underlying site git repo.

## Preview your site

To view your raw microsite in all it's glory, just append '/view' to the end of the site path in the address bar.

    eg. localhost:9292/yournewsite/view

## Layouts and Assets

To create a site layout just create a wiki page named `layout` and set it to the `erb` type. This file can contain arbitrary ERB. Inside the layout, `yield` where you want the wiki page content to go. For example:

```rhtml
<html>
  <body>
    <%= yield %>
  </body>
</html>
```

In your layout you have direct access to the [Gollum::Page](https://github.com/gollum/gollum-lib/blob/master/lib/gollum-lib/page.rb) object using `@page`. This lets you do things like get the page title, allowing for overrides from page metadata:

```rhtml
<title><%= @page.url_path_title %></title>
```

You can also add and edit javascript and css files directly from the wiki interface. For example, create a new wiki page named `/assets/stylesheets/main` and give it the `css` type, then drop this in:

```css
h1 { color: blue; }
```

To reference your new stylesheet, use the `static_path` helper:

```rhtml
<html>
  <head>
    <link rel="stylesheet" href="<%= static_path '/assets/stylesheets/main.css' %>" />
  <body>
    <%= yield %>
  </body>
</html>
```

The `static_path` helper is specifically for allowing you to view sites using the `/view` path as well as making it possible to view them from arbitrary domain names.

On production assets will be transparently compressed and cached. CSS and JS are compressed with YUI Compressor and PNG and JPEG with ImageOptim (if prerequisites are available). In addition, gzip compression will be transparently applied if the browser accepts it.

For image compression to work you'll need several prerequisites installed. See the [ImageOptim](https://github.com/toy/image_optim) documentation for instructions.

## CNAMEs

You can map sites to domain names by creating a wiki page named `cnames` in the root of your site. Each line in this wiki page is a domain name that the site will respond do. Every line after the first will automatically redirect to the first. For example:

```
www.petekeen.net
petekeen.net
www.peterkeen.com
```

In this example, `www.peterkeen.com` and `petekeen.net` will issue a 301 redirect to `www.petekeen.net`.

If you deploy this with nginx, make your sites application the default, like so:

```nginx
upstream sites {
    server localhost:7500 fail_timeout=0
}

server {
    # note the "default_server" part
    listen 80 default_server;

    # this is just an example so i'm omitting other interesting stuff here
    location {
      proxy_pass http://sites;
    }
}
```
	
## Features

* Creates new Gollum wikis on the fly
* Site-specific layouts
* Arbitrary CNAMEs for sites

## License

MIT
