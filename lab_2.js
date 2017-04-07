
var data = [];

//define row information
function row(d) {
  return {
    year: +d.year, // convert "Year" column to number
    gender: d.gender,
    winner_ace: +d.winner_ace,
    winner: d.winner,
    winner_country: d.winner_country,
  };
}
//define changeColorOnClick Function
var changeColorOnClick = (function(){
   var currentColor = "#ff0000";

    return function(){
        currentColor = currentColor == "#ff0000" ? "green" : "#ff0000";
        d3.select(this).style("fill", currentColor);
    }
})();

//load csv file
d3.csv("USOpenFinals_2016.csv", row, function(error, csv_data){
    csv_data.forEach(function (d) {
        data.push({ year: d.year, gender: d.gender, winner_ace: d.winner_ace, winner: d.winner, winner_country: d.winner_country });
    });


    var yscale = d3.scale.linear()
                    .domain([0, 15])
                    .range([350, 0]),
                yAxis = d3.svg.axis()
                    .orient('left')
                    .scale(yscale);
    var scale_year = d3.scale.linear()
                    .domain([2006, 2016])
                    .range([0, 600]);
                xAxis = d3.svg.axis()
                    .orient('bottom')
                    .scale(scale_year);

    var data_svg = d3.select("body")
    .append("svg")
        .attr("width", 1000)
        .attr("height", 1000);

    var data_g = data_svg.selectAll("circle")
        .data(data)
        .enter()
        .append("g")
        .filter(function(d) { return d.gender =="w"; });
    var data_circles = data_g.append("circle")
        .attr("cx", function(d) {
            return 50 + scale_year(d.year);
        })
        .attr("cy", function(d) {
            return yscale(d.winner_ace) ;
            //return yscale(d.winner_ace);
        })
        .attr("r", 20)
        .attr("fill", "#ff0000")
        .on("click",changeColorOnClick);

    var data_text = data_g.append("text")
        .text(function(d){return d.winner;})
        .attr("x", function(d) {
            return 50 + scale_year(d.year);
        })
        .attr("y", function(d) {
            return yscale(d.winner_ace) ;
            //return yscale(d.winner_ace);
        })
        .on("mouseover", function(d) {
            d3.select(this).text(function(d) { return d.winner_country;})
        })
        .on("mouseout", function(d){
            d3.select(this).text(function(d) { return d.winner;})
        })
    

    //draw the axes
    data_g.append('g')
          .attr('transform', 'translate(' + 30 + ',' + 0 + ')')
          .attr('class', 'y axis')
          .call(yAxis)
    data_g.append('g')
          .attr('transform', 'translate(' + 30 + ',' + 350 + ')')
          .attr('class', 'x axis')
          .call(xAxis)


});



