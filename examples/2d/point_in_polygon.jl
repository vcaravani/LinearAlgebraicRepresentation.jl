using LinearAlgebraicRepresentation, ViewerGL
Lar = LinearAlgebraicRepresentation
GL = ViewerGL

filename = "./test/svg/Lar.svg"
V,EV = Lar.svg2lar(filename)

GL.VIEW([
	GL.GLLines(V,EV,GL.COLORS[1]),
	GL.GLFrame2
]);

function pointsinout(V,EV, n=2_000_000)
	point_in = []
	point_out = []
	point_on = []
	classify = Lar.pointInPolygonClassification(V,EV)
	for k=1:n

		queryPoint = rand(1,2)
		inOut = classify(queryPoint)
		# println("k = $k, queryPoint = $queryPoint, inOut = $inOut")
		if inOut=="p_in"
			push!(point_in, queryPoint);
		elseif inOut=="p_out"
			push!(point_out, queryPoint);
		elseif inOut=="p_on"
			push!(point_on, queryPoint);
		end
	end
	#GL.GLPoints(queryPoint,GL.COLORS[2])
	return point_in,point_out,point_on
end


#using Random
#const rnglist = [MersenneTwister() for i in 1:Threads.nthreads()]

function pointsinout_multithreading(V,EV, n=2_000_000,t=Threads.nthreads())

	point_in = [[] for i in 1:t]
	point_out = [[] for i in 1:t]
	point_on = [[] for i in 1:t]

	classify = Lar.pointInPolygonClassification(V,EV)

	Threads.@threads for k=1:n

		#queryPoint = rand(rnglist[Threads.threadid()],1,2)
		queryPoint = rand(1,2)
		inOut = classify(queryPoint)
		# println("k = $k, queryPoint = $queryPoint, inOut = $inOut")
		if inOut=="p_in"
			push!(point_in[Threads.threadid()], queryPoint);
		elseif inOut=="p_out"
			push!(point_out[Threads.threadid()], queryPoint);
		elseif inOut=="p_on"
			push!(point_on[Threads.threadid()], queryPoint);
		end
	end
	#GL.GLPoints(queryPoint,GL.COLORS[2])
	return vcat(point_in...),vcat(point_out...),vcat(point_on...)
end

@btime points_in, points_out, points_on = pointsinout_multithreading(V,EV);
#@btime points_in, points_out, points_on = pointsinout(V,EV);

pointsin = [vcat(points_in...) zeros(length(points_in),1)]
pointsout = [vcat(points_out...) zeros(length(points_out),1)]

polygon = [GL.GLLines(V,EV,GL.COLORS[1])];
in_mesh = [GL.GLPoints(pointsin, GL.COLORS[2])]
out_mesh = [GL.GLPoints(pointsout, GL.COLORS[3])]

result = cat([polygon,in_mesh,out_mesh])
GL.VIEW(result);


#=

with @time macro:

n = 1_000_000
serial -> 167.890818 seconds (886.04 M allocations: 79.302 GiB, 31.84% gc time)
multithread -> 67.135810 seconds (886.26 M allocations: 79.323 GiB, 34.45% gc time)


n = 2_000_000
serial -> 173.068835 seconds (1.77 G allocations: 158.600 GiB, 19.59% gc time)
multithread -> 88.046785 seconds (1.77 G allocations: 158.630 GiB, 36.36% gc time)



with @btime macro:

n = 2_000_000
serial -> 216.330 s (1772000042 allocations: 158.60 GiB)
multithread -> 88.605 s (1780279949 allocations: 159.05 GiB)
=#
