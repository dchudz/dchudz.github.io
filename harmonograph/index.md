---
title: Harmonograph
layout: default
---

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

<div>
    <div id="harmonograph"></div>
    <h2>Settings</h2>
    Frequencies:
    <p>
    f<sub>0</sub>: <input id="frequency0" type="number" name="quantity" min=".1" max="10" step=.1 value="3">
    f<sub>1</sub>: <input id="frequency1" type="number" name="quantity" min=".1" max="10" step=.1 value="2">
    f<sub>2</sub>: <input id="frequency2" type="number" name="quantity" min=".1" max="10" step=.1 value="3">
  </p>
    Phases:
    <p>
    &Phi;<sub>0</sub>: <input id="phaseshift0" type="number" name="quantity" min=".1" max="10" step=.1 value="0">
    &Phi;<sub>1</sub>: <input id="phaseshift1" type="number" name="quantity" min=".1" max="10" step=.1 value="0">
    &Phi;<sub>2</sub>: <input id="phaseshift2" type="number" name="quantity" min=".1" max="10" step=.1 value="0">
  </p>

</div>

<div></div>
<script src="harmonograph.js" charset="utf-8"></script>

# About this Harmonograph

After looking at some pictures of harmonographs ([1](https://anitachowdry.wordpress.com/2014/07/11/iron-genie-at-the-museum-of-the-history-of-science-oxford/), [2](http://www.karlsims.com/harmonograph/)), it seems to me the two pendula attached to the pen can be approximated as two (probably orthogonal) vectors `$v_1$` and `$v_2$` that combine additively. The third pendulum adds an offset to the paper, so its effect is also additive.

So the position of the pen (relative to the paper) at time $t$ is:

`$$v_1 + v_2 + v_3$$`

where 

`$$v_i = \sin(f_i(t+\Phi_i))$$`

where `$f_i$` is the frequency of pendulum `$i$` and `$\Phi_i$` is an adjustment to the phase.

Assuming I'm thinking about this correctly so far, some things we could do next are:

- it would be nice if the path is still smooth even when you change the settings (currently it jumps)
  + (note: the [Lissijous curves](http://www.davidchudzicki.com/lissijous.html) achieve this)
- add a display showing where each of the pendulums is at each point in time?
- allow the user to change the direction of one of the pendulums?
- add friction