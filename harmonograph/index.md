---
title: Harmonograph
layout: default
---

<script src="http://d3js.org/d3.v3.min.js" charset="utf-8"></script>
<script src="sylvester.js" charset="utf-8"></script>


<style>
  #wrap {
   margin:0 auto;
   height:500px;
 }
 #left_col {
   float:left;
   width:20%;
 }
 #right_col {
   float:right;
   margin-left:20%;
   height:400px;
 }
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

<div id="wrap">
  <div id="left_col">
    <h3>frequency 0: <input id="frequency0" type="number" name="quantity" min=".1" max="10" step=.1 value="3"></h3>
    <h3>frequency 1: <input id="frequency1" type="number" name="quantity" min=".1" max="10" step=.1 value="2"></h3>
    <h3>frequency 2: <input id="frequency2" type="number" name="quantity" min=".1" max="10" step=.1 value="3"></h3>
    <h3>phase shift 0: <input id="phaseshift0" type="number" name="quantity" min=".1" max="10" step=.1 value="0"></h3>
    <h3>phase shift 1: <input id="phaseshift1" type="number" name="quantity" min=".1" max="10" step=.1 value="0"></h3>
    <h3>phase shift 2: <input id="phaseshift2" type="number" name="quantity" min=".1" max="10" step=.1 value="0"></h3>

  </div>
  <div id="right_col">
    <div id="lissijous"></div>
  </div>
</div>

<div></div>
<script src="harmonograph.js" charset="utf-8"></script>

# About this Harmonograph

hi

`$v_1 + v_2 + v_3$`