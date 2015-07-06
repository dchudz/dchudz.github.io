---
title: Harmonograph
layout: default
---

<link href="/libraries/nouislider/jquery.nouislider.min.css" rel="stylesheet">

<script src="/libraries/nouislider/jquery.nouislider.all.min.js"></script>

<script src="http://d3js.org/d3.v3.min.js" charset="utf-8"></script>
<script src="sylvester.js" charset="utf-8"></script>





<style>
 .chart {
  font-family: Arial, sans-serif;
  font-size: 10px;
}
.axis path, .axis line {
  fill: none;
  stroke: #000;
  shape-rendering: crispEdges;
}
.bar {
  fill: red;
}
#lissijous {  
  padding-top: 30px;  
  padding-right: 10px;  
  padding-bottom: 10px;  
  padding-left: 10px;  
}  
</style>

<script>
function clear() {
  svg.selectAll("*").remove()
}
</script>


<div>
    <div id="harmonograph"></div>
    <h2>Settings</h2>
    Frequencies:
    <div id="frequency_text_inputs"></div>
    <div id="frequency_inputs"></div>
    Phases:
    <div id="phase_text_inputs"></div>
    <div id="phase_inputs"></div>
    Amplitudes:
    <div id="amplitude_text_inputs"></div>
    <div id="amplitude_inputs"></div>

  Fade out old points? <input type="checkbox" id="fade"></p>

</div>

<div></div>
<script src="harmonograph.js" charset="utf-8"></script>

# About this Harmonograph

([source code](https://github.com/dchudz/dchudz.github.io/blob/master/harmonograph/harmonograph.js))

After talking with John Baez and looking at some pictures of harmonographs ([1](https://anitachowdry.wordpress.com/2014/07/11/iron-genie-at-the-museum-of-the-history-of-science-oxford/), [2](http://www.karlsims.com/harmonograph/)), it seems to me the two pendula attached to the pen can be approximated as two (probably orthogonal) vectors `$v_1$` and `$v_2$` that combine additively. The third pendulum adds an offset to the paper, so its effect is also additive.

So the position of the pen (relative to the paper) at time $t$ is:

`$$v_1 + v_2 + v_3$$`

where 

`$$v_i = A_i\sin(f_it + \Phi_i)$$`

where:

- `$f_i$` is the frequency of pendulum `$i$`,
-  `$\Phi_i$` is an adjustment to the phase,
-  `$A_i$` is the amplitude