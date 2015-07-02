

// These functions set up the sliders
////
function appendFrequencySlider(i, initial) {
	var frequencyInputsDiv = $("#frequency_inputs")
	var frequencyTextInputsDiv = $("#frequency_text_inputs")
	
	frequencyTextInputsDiv.append('f<sub>' + i + '</sub><input type="text" id="textinput_frequency' + i + '">')
	frequencyInputsDiv.append('<div width="50" id="frequency' + i + '"></div>')


	var slider = $("#frequency" + i);
	var input = $('#textinput_frequency' + i);

	slider.noUiSlider({
		step: .01,
		range: {
			'min': 0,
			'max': 6
		},
		start: [initial]
	});

	slider.Link('lower').to(input);

	slider.on({
	change: function(){
		clear();
	}
});
}

function appendPhaseSlider(i, initial) {
	var phaseInputsDiv = $("#phase_inputs")
	var phaseTextInputsDiv = $("#phase_text_inputs")
	
	phaseTextInputsDiv.append('f<sub>' + i + '</sub><input type="text" id="textinput_phase' + i + '">')
	phaseInputsDiv.append('<div width="50" id="phase' + i + '"></div>')


	var slider = $("#phase" + i);
	var input = $('#textinput_phase' + i);

	slider.noUiSlider({
		step: .01,
		range: {
			'min': 0,
			'max': 2*Math.PI
		},
		start: [initial]
	});

	slider.Link('lower').to(input);

	slider.on({
	change: function(){
		clear();
	}
});
}

function appendAmpSlider(i, initial) {
	var amplitudeInputsDiv = $("#amplitude_inputs")
	var amplitudeTextInputsDiv = $("#amplitude_text_inputs")
	
	amplitudeTextInputsDiv.append('f<sub>' + i + '</sub><input type="text" id="textinput_amplitude' + i + '">')
	amplitudeInputsDiv.append('<div width="50" id="amplitude' + i + '"></div>')


	var slider = $("#amplitude" + i);
	var input = $('#textinput_amplitude' + i);

	slider.noUiSlider({
		step: .01,
		range: {
			'min': 0,
			'max': 1
		},
		start: [initial]
	});

	slider.Link('lower').to(input);

	slider.on({
	change: function(){
		clear();
	}
});
}

appendFrequencySlider(0, 3);
appendFrequencySlider(1, 2);
appendFrequencySlider(2, 3.01);

appendPhaseSlider(0,0);
appendPhaseSlider(1,0);
appendPhaseSlider(2,0);

appendAmpSlider(0,1);
appendAmpSlider(1,1);
appendAmpSlider(2,1);


// A select element can't show any decimals
$('#html5').Link('lower').to($('#input-select'), null, wNumb({
	decimals: 0
}));

$('#html5').Link('upper').to($('#input-number'));

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
.domain([-2, 2])
.range([0, WIDTH]);

var y = d3.scale.linear()
.domain([-2, 2])
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
	1 * $("#phase0").val(), 
	1 * $("#phase1").val(),
	1 * $("#phase2").val()
	];
}

function getAmplitudes() {
	return [
	1 * $("#amplitude0").val(), 
	1 * $("#amplitude1").val(),
	1 * $("#amplitude2").val()
	];
}

var t=0;

function nextStep(oldPoint) {
	t = t + SPACE_STEP_SIZE;
	var freqs = getFreqs();
	$("#frequency0_value").val(freqs[0]);
	var phaseShifts = getPhaseShifts();
	var amps = getAmplitudes();

	var V0 = DIRECTION_0.multiply(amps[0]*Math.sin(t*freqs[0] + phaseShifts[0]))
	var V1 = DIRECTION_1.multiply(amps[1]*Math.sin(t*freqs[1] + phaseShifts[1]))
	var V2 = DIRECTION_2.multiply(amps[2]*Math.sin(t*freqs[2] + phaseShifts[2]))
	newVector = V0.add(V1).add(V2)
	newPoint = newVector.elements

	setTimeout(function () {
		nextStep(newPoint);
	}, TIME_STEP_DELAY);

	drawPoint(oldPoint, newPoint)

}

function clear() {
	t = 0;
	setTimeout(function () {
		svg.selectAll("*").remove();

	}, 100);
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
	.transition().duration(.5*TIME_STEP_DELAY*1000).style("opacity", 0).remove();
}


$( document ).ready(function() {
    nextStep([0,0]);
});
