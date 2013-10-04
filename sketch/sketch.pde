//http://mattmik.com/articles/ascii/ascii.html
//http://stackoverflow.com/questions/12331094/how-can-processing-js-detect-browsers-size
//https://github.com/ACassells/processing.js.SimpleWebCamInteraction & https://class.coursera.org/digitalmedia-001/forum/thread?thread_id=1255
//http://www.html5rocks.com/en/tutorials/getusermedia/intro/
//http://www.raymondcamden.com/index.cfm/2013/5/20/Capturing-camerapicture-data-without-PhoneGap


/* @pjs preload="andrew.jpg"; */
PImage img;
PGraphics pg;
var cellH, cellW, cols, rows;
var fontMeta = {
};
var imgPixelAvgBrightnessRegion = new Array();
var regionSize;
var closestBrightnessMatch = new Array();
var imgPixelBrightness = new Array();
var theFontSize = 10;
var fColor = 0;
var bColor = 255;

var ctx;
final int cameraWidth = 500;
final int cameraHeight = 500;

void setup() {
  size(500, 500);
  img = loadImage("andrew.jpg");

  PFont monospace = createFont("monospace", theFontSize);
  textFont(monospace);
  textSize(theFontSize);
  textAlign(LEFT, BOTTOM);
  cellH = int(textDescent() + textAscent());
  cellW = int(textWidth("a"));
  cols = int(width/cellW);
  rows = int(height/cellH);
  regionSize = cellW*cellH;

  //  for(var i=0; i<=126-33; i++){
  //    var l = String.fromCharCode(i+33);
  //    pg = createGraphics(cellW, cellH);
  //    pg.beginDraw();
  //    pg.background(0);
  //    pg.fill(255);
  //    pg.stroke(255);
  //    pg.textFont(monospace);
  //    pg.textSize(18);
  //    pg.textAlign(LEFT,BASELINE);
  //    pg.text(l,0,0);
  //    pg.loadPixels();
  //    var b = 0.0;
  //    for(var px=0; px<pg.pixels.length; px++){
  //       b += brightness(pg.pixels[px]);
  //        
  ////       console.log(l + " " +brightness + " " +c);
  //     }
  //     b = b / pg.pixels.length;
  //     fontMeta[l] = b;
  //    pg.endDraw();
  //  }

  rectMode(CORNER);
  for (var i=0; i<=126-33; i++) {
    var l = String.fromCharCode(i+33);
    fill(bColor);
    noStroke();
    rect(0, 0, cellW, cellH);
    fill(fColor);
    text(l, 0, 0+cellH);
    loadPixels();
    var b = 0.0;
    for (var x=0; x<cellW; x++) {
      for (var y=0; y<cellH; y++) {
        b += brightness(get(x, y));
      }
    }
    b = b / (cellW*cellH);
    fontMeta[l] = b;
  }

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
  //  console.log("font brightness levels: "+fontMeta);

  background(bColor);
}

void draw() {
//  if (!video.available) return;
//
//  // video is defined outside processing code
//  // draw image to the canvas so that we can read it back, even
//  // though I have set display:none for the video
//  // not sure is processingjs can read the video directly and skip this step?
//  ctx.drawImage(video, 0, 0, cameraWidth, cameraHeight);
//  img = get(0, 0, cameraWidth, cameraHeight);
  if (img != null) {
    calculateBrightnessOfEachPixel();
    //  drawBrightnessAsGrayValue();
    calculateAverageBrightnessOfRegionOfPixels();
    //  drawAvgBrightnessOfRegionOfPixels();
    findClosestBrightnessMatchFromCharArray();
    
    background(bColor);
    drawChars();
  }
}

void calculateBrightnessOfEachPixel() {
  pg = createGraphics(width, height);
  pg.beginDraw();
  pg.image(img, 0, 0, width, height);
  pg.loadPixels();
  for (var x=0; x<width; x++) {
    imgPixelBrightness[x] = new Array();
    for (var y=0; y<height; y++) {        
      //console.log("hmm" + imgPixelBrightness);
      imgPixelBrightness[x][y] = brightness(pg.pixels[y*width+x]);
    }
  }
  pg.endDraw();
  //  console.log("brightness of pixels "+imgPixelBrightness);
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
  for (var x=0; x<cols; x++) {
    imgPixelAvgBrightnessRegion[x] = new Array();
    for (var y=0; y<rows; y++) {
      // sum up brightness values of all pixels in the region
      var avgBrightness = 0.0;
      for (var i=0; i<cellW; i++) {
        for (var j=0; j<cellH; j++) {
          //console.log("x="+(x*cellW +i)+" y="+(y*cellH +j));
          avgBrightness += imgPixelBrightness[x*cellW +i][y*cellH +j];
          //console.log(avgBrightness);
        }
      }
      imgPixelAvgBrightnessRegion[x][y] = avgBrightness / regionSize;
    }
  }
  //  console.log("avg brightness " + imgPixelAvgBrightnessRegion);
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
  //console.log("match "+closestBrightnessMatch);
}

function drawChars() {
  fill(fColor);
  for (var x=0; x<cols; x++) {
    for (var y=0; y<rows; y++) {
      text(closestBrightnessMatch[x][y], x*cellW, y*cellH+cellH);
    }
  }
}

void resizeSketch(int w, int h) {
  if (w < 680) {
    size(w, floor(float(w)/680*610) - 30);
    } else size(680, 610 - 30);
}
