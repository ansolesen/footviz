var outerY = 1500;
var outerX = 1000;

var scaleX = d3.scale.linear()
    .domain([-5250, 5250])
    .range([0, 1500]);
var scaleY =d3.scale.linear()
    .domain([3400, -3400])
    .range([0, 1000]);
var scaleR = d3.scale.linear()
    .domain([0, 20])
    .range([0,10]);

var scaleColor = d3.scale.category10();

var svg = d3.select("body").append("svg")
    .attr("height", outerX)
    .attr("width", outerY);

var field = d3.select("svg").append("rect")
    .attr("x", 0)
    .attr("y", 0)
    .attr("height", outerX)
    .attr("width", outerY)
    .attr("fill", "lightgreen");



function render(data) {
    //bind data
    var player = svg.selectAll("circle").data(data);

    //enter face
    player.enter().append("circle")
        .attr("stroke", "black");

    //update face
    player
        .attr("r", function () {
            return scaleR(Math.floor(Math.random() * 40));
        })
        .attr("cx", function () {
            return scaleX(Math.floor(Math.random() * 5200));
        })
        .attr("cy", function () {
            return scaleY(Math.floor(Math.random() * 3400));
        })
        .transition()
        .delay(1000)
        .duration(2000)
        .attr("cx", function (d) {
            return scaleX(d.x);
        })
        .attr("cy", function (d) {
            return scaleY(d.y);
        })
        .attr("fill", function(d) {
            return scaleColor(d.shot);
        });

    //exit face
    player.exit().remove();

}
//function getColor(d) {
//    if (d.shot==="Shot on target") {
//        return "blue";
//    }else if (d.shot=="Goal") {
//        return "pink";
//    }
//    else {
//        return "green";
//    }
//}

function type(d){
    d.x = +d.x;
    d.y = +d.y;
    return d;
}
d3.csv("Mappe1.csv", type, render);