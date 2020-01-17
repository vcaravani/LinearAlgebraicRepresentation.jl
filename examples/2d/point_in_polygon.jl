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


using Random
const rnglist = [MersenneTwister() for i in 1:Threads.nthreads()]

function pointsinout_multithreading(V,EV, n=2_000_000,t=Threads.nthreads())

	point_in = [[] for i in 1:t]
	point_out = [[] for i in 1:t]
	point_on = [[] for i in 1:t]

	classify = Lar.pointInPolygonClassification(V,EV)

	Threads.@threads for k=1:n
		queryPoint = rand(rnglist[Threads.threadid()],1,2)
		#queryPoint = rand(1,2)
		inOut = classify(queryPoint)
		if inOut=="p_in"
			push!(point_in[Threads.threadid()], queryPoint);
		elseif inOut=="p_out"
			push!(point_out[Threads.threadid()], queryPoint);
		elseif inOut=="p_on"
			push!(point_on[Threads.threadid()], queryPoint);
		end
	end
	return vcat(point_in...),vcat(point_out...),vcat(point_on...)
end

using Distributed
#nprocs()
#addprocs(1)
#n_cpu = length(Sys.cpu_info()) or Sys.CPU_THREADS

function pointsinout_multiproc(V,EV, n=2_000_000,ws=Distributed.nworkers())

	point_in = [[] for i in 1:ws]
	point_out = [[] for i in 1:ws]
	point_on = [[] for i in 1:ws]
	# al posto di questi canale remoto??

	classify = Lar.pointInPolygonClassification(V,EV)

	@distributed for k=1:n

		# va fatta la chiamata remota
		queryPoint = rand(rnglist[Threads.threadid()],1,2)
		#queryPoint = rand(1,2)
		inOut = classify(queryPoint)
		if inOut=="p_in"
			push!(point_in[Threads.threadid()], queryPoint);
		elseif inOut=="p_out"
			push!(point_out[Threads.threadid()], queryPoint);
		elseif inOut=="p_on"
			push!(point_on[Threads.threadid()], queryPoint);
		end
	end

	#a,b,c, = fetch()

	return vcat(a),vcat(b),vcat(c)
end



#@time points_in, points_out, points_on = pointsinout_multiproc(V,EV)

@time points_in, points_out, points_on = pointsinout_multithreading(V,EV);
@time points_in, points_out, points_on = pointsinout(V,EV);

pointsin = [vcat(points_in...) zeros(length(points_in),1)]
pointsout = [vcat(points_out...) zeros(length(points_out),1)]

polygon = [GL.GLLines(V,EV,GL.COLORS[1])];
in_mesh = [GL.GLPoints(pointsin, GL.COLORS[2])]
out_mesh = [GL.GLPoints(pointsout, GL.COLORS[3])]

result = cat([polygon,in_mesh,out_mesh])
GL.VIEW(result);

#=

n = 2_000_000

with @btime macro:

serial -> 158.054 s (1772000042 allocations: 158.60 GiB)
multithread -> 51.618 s (1772000187 allocations: 158.62 GiB)
multithread with separate RNG for each thread -> 51.141 s (1772000205 allocations: 158.62 GiB)

=#
