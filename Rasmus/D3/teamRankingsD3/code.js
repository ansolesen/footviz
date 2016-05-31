var width = 700;
var height = 1024;

var position = "yellowCards";
var size = "rank";
var horizontal = "shots";

var options = [];

var allData;

d3.json("data/teamData.json", function(error, json) {
  allData = json;

  for (var key in allData[0]) {
    options.push(key);
  }

  //Remove the name option
  var index = options.indexOf("name");
  options.splice(index, 1 );

  createSelectors();
  createCircles();
  
  setSelectValue('position-selector', position);
  setSelectValue('size-selector', size);
  setSelectValue('horizontal-selector', horizontal);

});

function setSelectValue (id, val) {
    document.getElementById(id).value = val;
}



function createSelectors() {
  d3.select("#position-selector").selectAll("option").data(options).enter()
    .append('option')
    .text(function (d) { return d; });

  d3.select("#size-selector").selectAll("option").data(options).enter()
      .append('option')
      .text(function (d) { return d; });

  d3.select("#horizontal-selector").selectAll("option").data(options).enter()
      .append('option')
      .text(function (d) { return d; });

  d3.select("#horizontal-selector").on("change", horizontalUpdate);

  d3.select("#position-selector").on("change", positionUpdate);

  d3.select("#size-selector").on("change", sizeUpdate);
}

function positionUpdate() {
    position = this.options[this.selectedIndex].value;
    update(allData, position, size, horizontal);
}

function sizeUpdate() {
    size = this.options[this.selectedIndex].value;
    update(allData, position, size, horizontal);
}

function horizontalUpdate() {
    horizontal = this.options[this.selectedIndex].value;
    update(allData, position, size, horizontal);
}

function createCircles() {
  var svg = d3.select("body").append("svg")
            .attr("width", width)
            .attr("height", height);

  var circles = svg.selectAll("circle").data(allData);

  var text = svg.selectAll("text").data(allData);

  circles.enter().append("circle")
              .attr("fill", "none")
              .attr("stroke", "black");

  text.enter().append("text");

  update(allData, position, size, horizontal);
}

function sortByKey(array, key) {
  return array.sort(function(a, b) {
      var x = a[key]; var y = b[key];
      return ((x < y) ? -1 : ((x > y) ? 1 : 0));
  });
}

function sortByKeyReverse(array, key) {
  return array.sort(function(a, b) {
      var x = a[key]; var y = b[key];
      return ((x < y) ? 1 : ((x > y) ? -1 : 0));
  });
}

function update(data, positionAttribute, sizeAttribute, horizontalAttribute) {
  var prevRadius = 0;
  var prevY = 10;
  var prevX = 10;
  var distance = 10;

  var radiusMultiplier = 2;

  sortByKey(data, sizeAttribute);

  var currentRadius = 1;

  data.forEach(function(entry) {
    entry.radius = currentRadius * radiusMultiplier;
    currentRadius++;
  });

  sortByKeyReverse(data, positionAttribute);

  data.forEach(function(entry) {
    entry.y = prevY + prevRadius + distance + entry.radius;
    prevY = entry.y;
    prevRadius = entry.radius;
  });

  sortByKey(data, horizontalAttribute);

  prevRadius = 0;

  data.forEach(function(entry) {
    entry.x = prevX + prevRadius + distance + entry.radius;
    prevX = entry.x;
    prevRadius = entry.radius;
  });

  var svg = d3.select("svg");

  var circles = svg.selectAll("circle").data(data, function(d) {
    return d.radius;
  });

  var text = svg.selectAll("text").data(data, function(d) {
    return d.radius;
  });

  text.transition().duration(500)
      .attr("x", function(d) {return d.x + d.radius + 1;})
      .attr("y", function(d) {return d.y;})
      .text(function(d) {return d.name;});

  circles.transition().duration(500)
         .attr("r", function(d) {return d.radius})
         .attr("cx", function(d) {return d.x;})
         .attr("cy", function(d) {return d.y;});
}