//http://mattmik.com/articles/ascii/ascii.html
//http://stackoverflow.com/questions/12331094/how-can-processing-js-detect-browsers-size
//https://github.com/ACassells/processing.js.SimpleWebCamInteraction & https://class.coursera.org/digitalmedia-001/forum/thread?thread_id=1255
//http://www.html5rocks.com/en/tutorials/getusermedia/intro/
//http://www.raymondcamden.com/index.cfm/2013/5/20/Capturing-camerapicture-data-without-PhoneGap


/* @pjs preload="andrew.jpg, andrew-486x115.jpg, andrew-253x456.jpg"; */
PImage img;
PGraphics pg;
PFont monospace;
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

void setup() {
  size(500, 500);
  img = loadImage("andrew.jpg");
  
  monospace = createFont("monospace", theFontSize);
  textFont(monospace);
  textSize(theFontSize);
  textAlign(LEFT, BOTTOM);
  cellH = int(textDescent() + textAscent());
  cellW = int(textWidth("a"));
  cols = int(width/cellW);
  rows = int(height/cellH);
  regionSize = cellW*cellH;
  

  calculateBrightnessOfFont();
  normalizeFontTable();

  background(bColor);
}

void draw() {
  //size(window.innerWidth, window.innerHeight);
  
  if (img != null) {
    calculateBrightnessOfEachPixel();
    // drawBrightnessAsGrayValue();
    calculateAverageBrightnessOfRegionOfPixels();
    //  drawAvgBrightnessOfRegionOfPixels();
    findClosestBrightnessMatchFromCharArray();
    drawChars();
    
    img = null;
  }
}

void calculateBrightnessOfFont() {
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

void normalizeFontTable() {
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
}
void calculateBrightnessOfEachPixel() {
  pg = createGraphics(width, height);
  pg.beginDraw();
  pg.imageMode(CENTER);
  if(img.width < width){
    img.resize(width, 0);
  }
  if(img.height < height){
    img.resize(0, height);
  }
  pg.image(img, width/2, height/2);
  pg.loadPixels();
  for (var x=0; x<width; x++) {
    imgPixelBrightness[x] = new Array();
    for (var y=0; y<height; y++) {        
      //console.log("hmm" + imgPixelBrightness);
      imgPixelBrightness[x][y] = brightness(pg.pixels[y*width+x]);
    }
  }
  pg.endDraw();
  //console.log("brightness of pixels "+imgPixelBrightness);
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
  background(bColor);
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
  } 
  else size(680, 610 - 30);
}


