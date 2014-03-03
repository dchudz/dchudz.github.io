function compare(numbers::Array)
	sorted = sort(numbers)
	if length(unique(numbers)) != length(numbers)
		return 0
	elseif sorted == numbers
		return 1
	elseif sorted == reverse(numbers)
		return -1
	else 
		return 0
	end
end


points = DataFrame(x = [1, 4, 3, 2], y = [1, 5, 2, 4])

xcutoffs = sort(unique(points[:x]))
ycutoffs = sort(unique(points[:y]))

griddf = DataFrame(
	ixx=repeat([1:(length(xcutoffs)-1)], inner=[(length(ycutoffs)-1)]), 
	ixy=repeat([1:(length(ycutoffs)-1)], outer=[(length(xcutoffs)-1)]), 
);

griddf[:x_min] = xcutoffs[1:(end-1)][griddf[:ixx]]
griddf[:x_max] = xcutoffs[2:end][griddf[:ixx]]
griddf[:y_min] = ycutoffs[1:(end-1)][griddf[:ixy]]
griddf[:y_max] = ycutoffs[2:end][griddf[:ixy]]
griddf[:xmid] = (griddf[:x_min] + griddf[:x_max])/2
griddf[:ymid] = (griddf[:y_min] + griddf[:y_max])/2




griddf[:areasum] = 0


for (ixpoint1 in 1:nrow(points))
    for (ixpoint2 in (ixpoint1+1):nrow(points))
        for (ixgrid in 1:nrow(griddf))
            griddf[ixgrid,:areasum] += 
	            compare([points[ixpoint1,:x], griddf[ixgrid,:xmid], points[ixpoint2,:x]]) * 
	            compare([points[ixpoint1,:y], griddf[ixgrid,:ymid], points[ixpoint2,:y]])
        end
    end
end


maxabs = maximum(abs(griddf[:areasum]))
plot(
	layer(griddf, x_min=:x_min, x_max=:x_max, y_min=:y_min, y_max=:y_max, color=:areasum, Geom.rectbin),
	Scale.ContinuousColorScale(Scale.lab_gradient(color("green"), color("white"), color("red")), 
		minvalue=-maxabs, maxvalue=maxabs),
	layer(points, x=:x, y=:y, Geom.point),	
	Scale.x_continuous(minvalue=0, maxvalue=5),
	Scale.y_continuous(minvalue=0, maxvalue=5),
	Theme(panel_fill=color("white"), line_width=1mm, default_color=color("black"))
	)