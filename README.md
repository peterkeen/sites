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
	
## Features

* Creates new Gollum wikis on the fly
* Site-specific layouts
* Arbitrary CNAMEs for sites

## License

MIT
