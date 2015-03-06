# cymon-globe
Cymon data visualization using WebGL-Globe

## Building

To build this application you'll need an up-to-date copy of [Node.js](http://nodejs.org/), [Grunt CLI](http://gruntjs.com/), and [CoffeeScript](http://coffeescript.org/). Once all these are installed, simply run the following from within the `dataglobe` directory:

```
$ npm install
$ grunt
```
And everything will be built for you.

## Running

The easiest way to run this application is to use Python's built-in HTTP server. Simply run:

```
$ python -m SimpleHTTPServer 8080
```
And it will start a development server for you to view your work. In addition, you can also run

```
$ grunt watch
```
To have it watch for changes and automatically rebuild.
