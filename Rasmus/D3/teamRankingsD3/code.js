var width = 500;
var height = 1024;

var position = "yellowCards";
var size = "rank";

var options = [];

var allData;

d3.json("data/teamData.json", function(error, json) {
  allData = json;

  for (var key in allData[0]) {
    options.push(key);
  }

  createSelectors();
  createCircles();
});


function createSelectors() {
  d3.select("#position-selector").selectAll("option").data(options).enter()
    .append('option')
    .text(function (d) { return d; });

  d3.select("#size-selector").selectAll("option").data(options).enter()
      .append('option')
      .text(function (d) { return d; });

  d3.select("#position-selector").on("change", positionUpdate);

  d3.select("#size-selector").on("change", sizeUpdate);
}

function positionUpdate() {
    position = this.options[this.selectedIndex].value;
    update(allData, position, size);
}

function sizeUpdate() {
    size = this.options[this.selectedIndex].value;
    update(allData, position, size);
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

  update(allData, position, size);
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

function update(data, positionAttribute, sizeAttribute) {
  var prevRadius = 0;
  var prevY = 10;
  var distance = 10;
  var x = 100;

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

  var svg = d3.select("svg");

  var circles = svg.selectAll("circle").data(data, function(d) {
    return d.radius;
  });

  var text = svg.selectAll("text").data(data, function(d) {
    return d.radius;
  });

  text.transition().duration(500)
      .attr("x", x + 30)
      .attr("y", function(d) {return d.y;})
      .text(function(d) {return d.name;});

  circles.transition().duration(500)
         .attr("r", function(d) {return d.radius})
         .attr("cx", x)
         .attr("cy", function(d) {return d.y;});
}