var WIDTH = 500;
var HEIGHT = 400;
var SPACE_STEP_SIZE = .1;
var TIME_STEP_DELAY = .05;
var DIRECTION_0 = $V([0,1])
var DIRECTION_1 = $V([1,0])
var DIRECTION_2 = $V([1,1]).multiply(1/Math.sqrt(2))

var lineFunction = d3.svg.line()
.x(function (d) {
	return x(d[0]);
})
.y(function (d) {
	return y(d[1]);
})
.interpolate("linear");

var x = d3.scale.linear()
.domain([-3, 3])
.range([0, WIDTH]);

var y = d3.scale.linear()
.domain([-3, 3])
.range([HEIGHT, 0]);

//Create SVG element
var svg = d3.select("#harmonograph")
.append("svg")
.attr("width", WIDTH)
.attr("height", HEIGHT);

function getFreqs() {
	return [
	1 * $("#frequency0").val(), 
	1 * $("#frequency1").val(),
	1 * $("#frequency2").val()
	];
}

function getPhaseShifts() {
	return [
	1 * $("#phaseshift0").val(), 
	1 * $("#phaseshift1").val(),
	1 * $("#phaseshift2").val()
	];
}


function nextStep(t, oldPoint) {

	var freqs = getFreqs();
	var phaseShifts = getPhaseShifts();

	var V0 = DIRECTION_0.multiply(Math.sin((t+phaseShifts[0])*freqs[0]))
	var V1 = DIRECTION_1.multiply(Math.sin((t+phaseShifts[1])*freqs[1]))
	var V2 = DIRECTION_2.multiply(Math.sin((t+phaseShifts[2])*freqs[2]))
	newVector = V0.add(V1).add(V2)
	newPoint = newVector.elements

	setTimeout(function () {
		nextStep(t + SPACE_STEP_SIZE, newPoint);
	}, TIME_STEP_DELAY);

	drawPoint(oldPoint, newPoint)

}

function clear() {
	svg.selectAll("*").remove()
}

$(":input").bind('keyup mouseup', function () {
	clear();
});



function drawPoint(oldPoint, newPoint) {
	if ($("#fade").is(':checked')) {
		fadeRate = 8000;
	} else {
		fadeRate = Infinity;
	}
	
	svg.append("path")
	.attr("d", lineFunction([oldPoint, newPoint]))

	.attr("stroke", "red")
	.attr("stroke-WIDTH", 2)
	.attr("fill", "none")
	.transition().duration(fadeRate).style("opacity", 0).remove();

	svg.append("circle")
	.attr("cx", x(newPoint[0]))
	.attr("cy", y(newPoint[1]))
	.attr("r", 2)
	.transition().duration(fadeRate).style("opacity", 0).remove();
}

nextStep(0, [0,0]);