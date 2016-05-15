/**
 * Created by SBK on 11-05-2016.
 */
var w = 700,
    h = 500;
var NoVar = 5;
var colorscale = d3.scale.category10();
var teamsToshow = [0,1,2,3,4,5,6,7,8,9,10,11];


var LegendOptions=[];
d3.csv("teams.csv", type, function (t) {
    for (var i=0;i<teamsToshow.length;i++) {
        LegendOptions.push(t[teamsToshow[i]].x);
    }
    d3.csv("data.csv", type, function (d) {
        dataWrapper(d);
    });
});


var chosenTeams = [2];
function Selecters() {
    var selectors = d3.select("body").append("selector")
        .attr("height","200px")
        .attr("width","200px")
        .attr("z-index",1);

    var select = d3.select('selector')
        .append('select')
        .attr('class', 'select')
        .on('change', onchange());

    var select2 = d3.select('selector')
        .append('select')
        .attr('class', 'select2')
        .on('change', onchange2());

    var options2 = select2
        .selectAll('option')
        .data(LegendOptions).enter()
        .append('option')
        .text(function (d) { return d; });

    var options = select
        .selectAll('option')
        .data(LegendOptions).enter()
        .append('option')
        .text(function (d) { return d; });

    function onchange() {
        console.log("hej med jer");
        // chosenTeams[0] = this.selectedIndex;
        // if (chosenTeams[0]!=null&&chosenTeams[1]!=null) {
        //     RadarChart.draw("#chart", chosenTeams, mycfg);
        // }
    }
    function onchange2() {
        console.log("hej");
        // chosenTeams[1] = this.selectedIndex;
        // if (chosenTeams[0]!=null&&chosenTeams[1]!=null) {
        //     RadarChart.draw("#chart", chosenTeams, mycfg);
        // }
    }


}




function type(d){
    d.value = parseFloat(d.value);
    return d;
}

function dataWrapper(array) {
    var data = [];
    for (var i=0;i<teamsToshow.length;i++) {
        var current = [];
        for (var k=teamsToshow[i]*NoVar;k<=(teamsToshow[i]*NoVar)+NoVar-1;k++) {
            console.log(array[k]);
            console.log("k:"+k);
            console.log("i"+i);
            console.log("teamstoshow max"+(teamsToshow[i]*NoVar+NoVar-1));
            console.log("teamstoshow"+teamsToshow[i]);
            current.push(array[k]);
        }
        data.push(current);
    }
    console.log(data);



    RadarChart.draw("#chart", data, mycfg);
    legdend();
    Selecters();

    console.log(LegendOptions);
}





// function dataWrapper(array) {
//     var data = [];
//     for (var i=0;i<array.length;i++) {
//         var current = [];
//         for (var k=i;k<NoVar+i;k++) {
//             current.push(array[k]);
//         }
//         data.push(current);
//         i += 4;
//     }
//
//     RadarChart.draw("#chart", data, mycfg);
//     legdend();
//     console.log(LegendOptions);
// }



// function type(d){
//     d.value = parseFloat(d.value);
//     return d;
// }
// var dataArray = [];
//
// function load (files) {
//     for (var i=0;i<files.length;i++) {
//         d3.csv(files[i], type, function (d) {
//
//         });
//     }
//     d3.csv(name, type, function (d) {
//         dataArray.push(d);
//         load();
//     });
//
// }
//
// d3.csv("data2.csv",type,function (d) {
//     dataArray.push(d);
//     d3.csv("data1.csv",type,function (t) {
//         dataArray.push(t);
//         RadarChart.draw("#chart", dataArray, mycfg);
//         legdend();
//     });
// });




//Legend titles

//var LegendOptions = ['Bronby IF','AGF'];


//Options for the Radar chart, other than default
var mycfg = {
    w: 600,
    h: 600,
    maxValue: 1,
    levels: 5,
    ExtraWidthX: 300,
    color: colorscale,
    radius: 7,
    LegendOptions: LegendOptions
};

//Call function to draw the Radar chart
//Will expect that data is in %'s
// RadarChart.draw("#chart", d, mycfg);

////////////////////////////////////////////
/////////// Initiate legend ////////////////
////////////////////////////////////////////
function legdend() {
    var svg = d3.select('#body')
        .selectAll('svg')
        .append('svg')
        .attr("width", w + 300)
        .attr("height", h);

//Create the title for the legend
    var text = svg.append("text")
        .attr("class", "title")
        .attr('transform', 'translate(90,0)')
        .attr("x", w - 70)
        .attr("y", 10)
        .attr("font-size", "12px")
        .attr("fill", "#404040")
        .text("SuccesRate in %");

//Initiate Legend
    var legend = svg.append("g")
        .attr("class", "legend")
        .attr("height", 100)
        .attr("width", 200)
        .attr('transform', 'translate(90,20)')
        ;
//Create colour squares
    legend.selectAll('rect')
        .data(LegendOptions)
        .enter()
        .append("rect")
        .attr("x", w - 65)
        .attr("y", function(d, i){ return i * 20;})
        .attr("width", 10)
        .attr("height", 10)
        .style("fill", function(d, i){ return colorscale(i);})
    ;
//Create text next to squares
    legend.selectAll('text')
        .data(LegendOptions)
        .enter()
        .append("text")
        .attr("x", w - 52)
        .attr("y", function(d, i){ return i * 20 + 9;})
        .attr("font-size", "11px")
        .attr("fill", "#737373")
        .text(function(d) { return d; })
    ;
}
