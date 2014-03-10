using Gadfly
using DataFrames

# if the numbers are distinct and monotonic, return -1 or 1 depending on the order
# otherwise, return 0
function compare(numbers::Array)
	sorted = unique(sort(numbers))
	if sorted == numbers
		return 1
	elseif sorted == reverse(numbers)
		return -1
	else 
		return 0
	end
end

# the boundaries of our rectangles will conist of all x- and y- coordinates of
# the points. 
function covariance_rectangles_plot(pointsdf)
	xcutoffs = sort(unique(pointsdf[:x]))
	ycutoffs = sort(unique(pointsdf[:y]))
	griddf = DataFrame(
		ixx=repeat([1:(length(xcutoffs)-1)], inner=[(length(ycutoffs)-1)]), 
		ixy=repeat([1:(length(ycutoffs)-1)], outer=[(length(xcutoffs)-1)]), 
	)
	griddf[:x_min] = xcutoffs[1:(end-1)][griddf[:ixx]]
	griddf[:x_max] = xcutoffs[2:end][griddf[:ixx]]
	griddf[:y_min] = ycutoffs[1:(end-1)][griddf[:ixy]]
	griddf[:y_max] = ycutoffs[2:end][griddf[:ixy]]
	griddf[:xmid] = (griddf[:x_min] + griddf[:x_max])/2
	griddf[:ymid] = (griddf[:y_min] + griddf[:y_max])/2
	griddf[:areasum] = 0
	for (ixpoint1 in 1:nrow(pointsdf))
	    for (ixpoint2 in (ixpoint1+1):nrow(pointsdf))
	        for (ixgrid in 1:nrow(griddf))
	            griddf[ixgrid,:areasum] += 
		            compare([pointsdf[ixpoint1,:x], griddf[ixgrid,:xmid], pointsdf[ixpoint2,:x]]) * 
		            compare([pointsdf[ixpoint1,:y], griddf[ixgrid,:ymid], pointsdf[ixpoint2,:y]])
	        end
	    end
	end
	maxabs = maximum(abs(griddf[:areasum]))
	plot(
		layer(griddf, x_min=:x_min, x_max=:x_max, y_min=:y_min, y_max=:y_max, color=:areasum, Geom.rectbin),
		Scale.ContinuousColorScale(Scale.lab_gradient(color("green"), color("white"), color("red")), 
			minvalue=-maxabs, maxvalue=maxabs),
		layer(pointsdf, x=:x, y=:y, Geom.point),	
		Theme(panel_fill=color("white"), line_width=1mm, default_color=color("black"))
		)
end