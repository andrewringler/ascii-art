//http://mattmik.com/articles/ascii/ascii.html
//http://stackoverflow.com/questions/12331094/how-can-processing-js-detect-browsers-size
//https://github.com/ACassells/processing.js.SimpleWebCamInteraction & https://class.coursera.org/digitalmedia-001/forum/thread?thread_id=1255
//http://www.html5rocks.com/en/tutorials/getusermedia/intro/
//http://www.raymondcamden.com/index.cfm/2013/5/20/Capturing-camerapicture-data-without-PhoneGap
//http://www.codealias.info/technotes/javascript_for_getting_flickr_images_with_tags
//http://www.flickr.com/groups/api/discuss/72157629144244216/
//https://developer.mozilla.org/en-US/docs/HTML/CORS_Enabled_Image?redirectlocale=en-US&redirectslug=CORS_Enabled_Image
//https://processing-js.lighthouseapp.com/projects/41284-processingjs/tickets/1927

/* @pjs preload="andrew.jpg, andrew-486x115.jpg, andrew-253x456.jpg"; */
PImage img, imgNext;
PGraphics pg;
PFont monospace;
var cellH, cellW, cols, rows;
var fontMeta = {
};
var ctx;
var imgPixelAvgBrightnessRegion;
var regionSize;
var closestBrightnessMatch;
var imgPixelBrightness;
var theFontSize = 10;
var fColor = 0;
var bColor = 255;
var drawWidth, drawHeight;
var recalc;
var redraw = true;
var TOOL_HEIGHT = 150;

void setup() {
  size(100, 100);
  frameRate(5);
  ctx = externals.context;
  drawWidth = 0;
  drawHeight = 0;
  img = loadImage("andrew.jpg");
  
  monospace = createFont("monospace", theFontSize);
  textFont(monospace);
  textSize(theFontSize);
  textAlign(LEFT, BOTTOM);
  cellH = int(textDescent() + textAscent());
  cellW = int(textWidth("a"));
  regionSize = cellW*cellH;

  calculateBrightnessOfFont();
  normalizeFontTable();
}

void draw() {
  var newWidth = window.innerWidth;
  var newHeight = int(window.innerHeight - TOOL_HEIGHT);
  if(newWidth != width || newHeight != height){
    size(newWidth, newHeight);
    redraw = true;
  }
  cols = int(width/cellW);
  rows = int(height/cellH);

  if (img != null) {
    if(drawHeight != height || drawWidth != width || recalc){
      calculateBrightnessOfEachPixel();
      calculateAverageBrightnessOfRegionOfPixels();
      findClosestBrightnessMatchFromCharArray();
      recalc = false;
      redraw = true;
    }
    if(redraw){
      //drawBrightnessAsGrayValue();
      //drawAvgBrightnessOfRegionOfPixels();
      drawChars();
      redraw = false;
    }
    
    if(newImageLoaded != undefined && newImageLoaded){
        console.log("loading new image");
        img = loadImage(newImageSrc);
        //image(img, 0, 0, width, height);
        //text("hello", 50, 50);
        recalc = true;
        newImageLoaded = false;
    }
    
    drawWidth = width;
    drawHeight = height;
  }
}

function calculateBrightnessOfFont() {
  pg = createGraphics(cellW, cellH);
  pg.beginDraw();
  pg.rectMode(CORNER);
  pg.noStroke();
  pg.textFont(monospace);
  pg.textSize(theFontSize);
  pg.textAlign(LEFT, BOTTOM);

  for (var i=0; i<=126-33; i++) {
    var l = String.fromCharCode(i+33);
    pg.fill(bColor);
    pg.rect(0, 0, cellW, cellH);
    pg.fill(fColor);
    pg.text(l, 0, 0+cellH);
    pg.loadPixels();
    var b = 0.0;
    for (var x=0; x<cellW; x++) {
      for (var y=0; y<cellH; y++) {
        b += brightness(pg.pixels[y*cellW+x]);
      }
    }
    b = b / (cellW*cellH);
    fontMeta[l] = b;
  }
  pg.endDraw();
}

function normalizeFontTable() {
  // scale
  var min = 255;
  var max = 0;
  for (var i=0; i<=126-33; i++) {
    var l = String.fromCharCode(i+33);
    var b = fontMeta[l];
    if (b < min) {
      min = b;
    }
    if (b > max) {
      max = b;
    }
  }
  for (var i=0; i<=126-33; i++) {
    var l = String.fromCharCode(i+33);
    var b = fontMeta[l];
    fontMeta[l] = 255*(b-min) / (max-min);
  }
}

function calculateBrightnessOfEachPixel() {
  imgPixelBrightness = new Array();
  pg = createGraphics(width, height);
  pg.beginDraw();
  pg.imageMode(CENTER);
  var scaleFactor = 1.0;
  scaleFactor = width / img.width;
  scaleFactor = max(scaleFactor, height / img.height);
  pg.image(img, width/2, height/2, img.width*scaleFactor, img.height*scaleFactor);
  pg.loadPixels();
  for (var x=0; x<width; x++) {
    imgPixelBrightness[x] = new Array();
    for (var y=0; y<height; y++) {        
      //console.log("hmm" + imgPixelBrightness);
      imgPixelBrightness[x][y] = brightness(pg.pixels[y*width+x]);
    }
  }
  pg.endDraw();
}

function drawBrightnessAsGrayValue() {
  background(0);
  for (var x=0; x<width; x++) {
    for (var y=0; y<height; y++) {
      stroke(imgPixelBrightness[x][y]);      
      point(x, y);
    }
  }
}

function calculateAverageBrightnessOfRegionOfPixels() {
  imgPixelAvgBrightnessRegion = new Array();
  for (var x=0; x<cols; x++) {
    imgPixelAvgBrightnessRegion[x] = new Array();
    for (var y=0; y<rows; y++) {
      // sum up brightness values of all pixels in the region
      var avgBrightness = 0.0;
      for (var i=0; i<cellW; i++) {
        for (var j=0; j<cellH; j++) {
          avgBrightness += imgPixelBrightness[x*cellW +i][y*cellH +j];
        }
      }
      imgPixelAvgBrightnessRegion[x][y] = avgBrightness / regionSize;
    }
  }
}

function drawAvgBrightnessOfRegionOfPixels() {
  background(0);
  rectMode(CORNER);
  noStroke();
  for (var x=0; x<cols; x++) {
    for (var y=0; y<rows; y++) {
      fill(imgPixelAvgBrightnessRegion[x][y]);
      rect(x*cellW, y*cellH, cellW, cellH);
    }
  }
}

function findClosestBrightnessMatchFromCharArray() {
  closestBrightnessMatch = new Array();
  for (var x=0; x<cols; x++) {
    closestBrightnessMatch[x] = new Array();
    for (var y=0; y<rows; y++) {
      var avg = imgPixelAvgBrightnessRegion[x][y];
      // find closest brightness match
      var bestDiff = 255;
      var theChar = "-";
      for (var k=0; k<=126-33; k++) {
        var curChar = String.fromCharCode(k+33);
        var b = fontMeta[curChar];
        var diff = abs(avg - b);
        if (diff < bestDiff) {
          bestDiff = diff;
          theChar = curChar;
        }
      }
      closestBrightnessMatch[x][y] = theChar;
    }
  }
}

function drawChars() {
  background(bColor);
  fill(fColor);
  for (var x=0; x<cols; x++) {
    for (var y=0; y<rows; y++) {
      text(closestBrightnessMatch[x][y], x*cellW, y*cellH+cellH);
    }
  }
}


