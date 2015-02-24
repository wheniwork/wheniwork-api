When I Work API Documentation
========

This is the source for the API documentation of [When I Work](http://www.wheniwork.com). If you're looking for the actual documentation page, it can be found at [http://wheniwork.github.io](http://wheniwork.github.io).

Editing the Documentation
------------------------------

### Prerequisites

You're going to need:

 - **Ruby, version 1.9.3 or newer**
 - **Bundler** — If Ruby is already installed, but the `bundle` command doesn't work, just run `gem install bundler` in a terminal.

### Getting Set Up

 1. Fork this repository on Github.
 2. Clone *your forked repository* to your hard drive with `git clone https://github.com/YOURUSERNAME/wheniwork-api.git`
 3. `cd wheniwork-api`
 4. Install all dependencies: `bundle install`
 5. Start the test server: `bundle exec middleman server`

You can now see the docs at <http://localhost:4567>. And as you edit `source/index.md`, your server should automatically update! Whoa! That was fast!

Now that the API docs are all set up your machine, you'll probably want to learn more about [editing Slate markdown](https://github.com/tripit/slate/wiki/Markdown-Syntax).
