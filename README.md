# cymon-globe
Cymon data visualization using WebGL-Globe

## Building

To build this application you'll need an up-to-date copy of [Node.js](http://nodejs.org/), [Grunt CLI](http://gruntjs.com/), and [CoffeeScript](http://coffeescript.org/). Once all these are installed, simply run the following from within the `cymon-globe` directory:

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

## TODOs

* [ ] When a category is toggled in the legend, update the colours for all the other points in the visualization given that there may now be a new max data value
* [ ] When two or more categories have a point at the same lat/long (with a certain fuzz factor), rather than overlaying the multiple points be smarter and add their values together
* [ ] Re-evaluate colour thresholds for data points. Using the max value in the data skews everything to the low-end due to having just a couple outliers
* [ ] Re-evaluate colours for the heatmap. Fully saturated red, green, and blue as the interval points is a bit... boring
