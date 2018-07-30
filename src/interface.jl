
	"""
		characteristicMatrix( FV::Cells )::ChainOp
	
	Binary matrix representing by rows the `p`-cells of a cellular complex.
	The input parameter must be of `Cells` type. Return a sparse binary matrix, 
	providing the basis of a ``Chain`` space of given dimension. Notice that the 
	number of columns is equal to the number of vertices (0-cells). for a g
	
	# Example
	
	```julia
	V,(VV,EV,FV,CV) = cuboid([1.,1.,1.], true); 
	
	julia> full(characteristicMatrix(FV))
	6×8 Array{Int8,2}:
	 1  1  1  1  0  0  0  0
	 0  0  0  0  1  1  1  1
	 1  1  0  0  1  1  0  0
	 0  0  1  1  0  0  1  1
	 1  0  1  0  1  0  1  0
	 0  1  0  1  0  1  0  1

	julia> full(characteristicMatrix(CV))
	1×8 Array{Int8,2}:
	 1  1  1  1  1  1  1  1

	julia> full(characteristicMatrix(EV))
	12×8 Array{Int8,2}:
	 1  1  0  0  0  0  0  0
	 0  0  1  1  0  0  0  0
	 0  0  0  0  1  1  0  0
	 0  0  0  0  0  0  1  1
	 1  0  1  0  0  0  0  0
	 0  1  0  1  0  0  0  0
	 0  0  0  0  1  0  1  0
	 0  0  0  0  0  1  0  1
	 1  0  0  0  1  0  0  0
	 0  1  0  0  0  1  0  0
	 0  0  1  0  0  0  1  0
	 0  0  0  1  0  0  0  1
	```
	"""
   function characteristicMatrix( FV::Cells )::ChainOp
      I,J,V = Int64[],Int64[],Int8[] 
      for f=1:length(FV)
         for k in FV[f]
            push!(I,f)
            push!(J,k)
            push!(V,1)
         end
      end
      M_2 = sparse(I,J,V)
      return M_2
   end
   
   
	"""
		boundary_1( EV::Cells )::ChainOp
	
	Computation of sparse signed boundary operator ``C_1 -> C_0``.
	
	# Example
	```
	julia> V,(VV,EV,FV,CV) = cuboid([1.,1.,1.], true);

	julia> EV
	12-element Array{Array{Int64,1},1}:
	 [1, 2]
	 [3, 4]
	   ...
	 [2, 6]
	 [3, 7]
	 [4, 8]

	julia> boundary_1( EV::Cells )
	8×12 SparseMatrixCSC{Int8,Int64} with 24 stored entries:
	  [1 ,  1]  =  -1
	  [2 ,  1]  =  1
	  [3 ,  2]  =  -1
		...       ...
	  [7 , 11]  =  1
	  [4 , 12]  =  -1
	  [8 , 12]  =  1

	julia> full(boundary_1(EV::Cells))
	8×12 Array{Int8,2}:
	 -1   0   0   0  -1   0   0   0  -1   0   0   0
	  1   0   0   0   0  -1   0   0   0  -1   0   0
	  0  -1   0   0   1   0   0   0   0   0  -1   0
	  0   1   0   0   0   1   0   0   0   0   0  -1
	  0   0  -1   0   0   0  -1   0   1   0   0   0
	  0   0   1   0   0   0   0  -1   0   1   0   0
	  0   0   0  -1   0   0   1   0   0   0   1   0
	  0   0   0   1   0   0   0   1   0   0   0   1
	```
	"""
   function boundary_1( EV::Cells )::ChainOp
      sp_boundary_1 = characteristicMatrix(EV)'
      for e = 1:length(EV)
         sp_boundary_1[EV[e][1],e] = -1
      end
      return sp_boundary_1
   end
   



	"""
   		coboundary_0(EV::LARLIB.Cells)
   		
   	Return the `coboundary_0` signed operator `C_0` -> `C_1`.
	"""
   coboundary_0(EV::Cells) = boundary_1(EV::Cells)'
   
   
   
	"""
		u_coboundary_1( FV::Cells, EV::::Cells)::ChainOp
	
	Compute the sparse *unsigned* coboundary_1 operator ``C_1 -> C_2``.
	Notice that the output matrix is `m x n`, where `m` is the number of faces, and `n` 
	is the number of edges.
	
	# Example
	
	```julia
	julia> V,(VV,EV,FV,CV) = LARLIB.cuboid([1.,1.,1.], true);
	
	julia> u_coboundary_1(FV,EV)
	6×12 SparseMatrixCSC{Int8,Int64} with 24 stored entries:
	  [1 ,  1]  =  1
	  [3 ,  1]  =  1
	  [1 ,  2]  =  1
	  [4 ,  2]  =  1
		...		...
	  [4 , 11]  =  1
	  [5 , 11]  =  1
	  [4 , 12]  =  1
	  [6 , 12]  =  1

	julia> full(u_coboundary_1(FV,EV))
	6×12 Array{Int8,2}:
	 1  1  0  0  1  1  0  0  0  0  0  0
	 0  0  1  1  0  0  1  1  0  0  0  0
	 1  0  1  0  0  0  0  0  1  1  0  0
	 0  1  0  1  0  0  0  0  0  0  1  1
	 0  0  0  0  1  0  1  0  1  0  1  0
	 0  0  0  0  0  1  0  1  0  1  0  1
	 
	julia> unsigned_boundary_2 = u_coboundary_1(FV,EV)';
	```
	"""
   function u_coboundary_1( FV::LARLIB.Cells, EV::LARLIB.Cells)::LARLIB.ChainOp
      cscFV = LARLIB.characteristicMatrix(FV)
      cscEV = LARLIB.characteristicMatrix(EV)
      temp = cscFV * cscEV'
      I,J,V = Int64[],Int64[],Int8[]
      for j=1:size(temp,2)
         for i=1:size(temp,1)
            if temp[i,j] == 2
               push!(I,i)
               push!(J,j)
               push!(V,1)
            end
         end
      end
      sp_u_coboundary_1 = sparse(I,J,V)
      return sp_u_coboundary_1
   end
      



	"""
   		u_boundary_2(FV::LARLIB.Cells, EV::LARLIB.Cells)::LARLIB.ChainOp
   		
   	Return the unsigned `boundary_2` operator `C_2` -> `C_1`.
	"""
	u_boundary_2(EV, FV) = (LARLIB.u_coboundary_1(FV, EV))'
   
   
   
   
   
	"""
	Local utility function. Storage of information need to build face cycles.
	"""
   function columninfo(infos,EV,next,col)
       infos[1,col] = 1
       infos[2,col] = next
       infos[3,col] = EV[next][1]
       infos[4,col] = EV[next][2]
       vpivot = infos[4,col]
   end
   
   
	"""
		coboundary_1( FV::Cells, EV::Cells)::ChainOp

	Compute the sparse *signed* coboundary_2 operator ``C_1 -> C_2``.
	The sparse matrix generated by `coboundary_2` contains by row a representation 
	of faces as oriented cycles of edges. The orientation of cycles is arbitrary
	```	
	julia> coboundary_2( FV,EV )
	6×12 SparseMatrixCSC{Int8,Int64} with 24 stored entries:
	  [1 ,  1]  =  -1
	  [3 ,  1]  =  -1
	  [1 ,  2]  =  1
	  [4 ,  2]  =  -1
		...		  ...	
	  [4 , 11]  =  1
	  [5 , 11]  =  -1
	  [4 , 12]  =  -1
	  [6 , 12]  =  -1

	julia> full(coboundary_2( FV,EV ))
	6×12 Array{Int8,2}:
	 -1   1   0  0   1  -1  0   0  0   0   0   0
	  0   0  -1  1   0   0  1  -1  0   0   0   0
	 -1   0   1  0   0   0  0   0  1  -1   0   0
	  0  -1   0  1   0   0  0   0  0   0   1  -1
	  0   0   0  0  -1   0  1   0  1   0  -1   0
	  0   0   0  0   0  -1  0   1  0   1   0  -1
	  
	  	 
	julia> boundary_2(FV,EV) = coboundary_2(FV,EV)'
	12×6 Array{Int8,2}:
	 -1   0  -1   0   0   0
	  1   0   0  -1   0   0
	  0  -1   1   0   0   0
		...			...
	  0   0  -1   0   0   1
	  0   0   0   1  -1   0
	  0   0   0  -1   0  -1
	```	
	"""
   function coboundary_1( FV::Cells, EV::Cells)::ChainOp
       sp_u_coboundary_1 = u_coboundary_1(FV,EV)
       larEV = characteristicMatrix(EV)
       # unsigned incidence relation
       FE = [findn(sp_u_coboundary_1[f,:]) for f=1:size(sp_u_coboundary_1,1) ]
       I,J,V = Int64[],Int64[],Int8[]
       vedges = [findn(larEV[:,v]) for v=1:size(larEV,2)]
   
       # Loop on faces
       for f=1:length(FE)
           fedges = Set(FE[f])
           next = pop!(fedges)
           col = 1
           infos = zeros(Int64,(4,length(FE[f])))
           vpivot = infos[4,col]
           vpivot = columninfo(infos,EV,next,col)
           while fedges != Set()
               nextedge = intersect(fedges, Set(vedges[vpivot]))
               fedges = setdiff(fedges,nextedge)
               next = pop!(nextedge)
               col += 1
               vpivot = columninfo(infos,EV,next,col)
               if vpivot == infos[4,col-1]
                   infos[3,col],infos[4,col] = infos[4,col],infos[3,col]
                   infos[1,col] = -1
                   vpivot = infos[4,col]
               end
           end
           for j=1:size(infos,2)
               push!(I, f)
               push!(J, infos[2,j])
               push!(V, infos[1,j])
           end
       end
       
       sp_coboundary_1 = sparse(I,J,V)
       return sp_coboundary_1
   end
   

   
   	
	"""
		chaincomplex( W::Points, EW::Cells )::Tuple{Array{Cells,1},Array{ChainOp,1}}
	
	Chain 2-complex construction from basis of 1-cells. 
	
	From the minimal input, construct the whole
	two-dimensional chain complex, i.e. the bases for linear spaces C_1 and 
	C_2 of 1-chains and  2-chains, and the signed coboundary operators from 
	C_0 to C_1 and from C_1 to C_2.
	
	# Example
	```julia
	julia> W = 
	 [0.0  0.0  0.0  0.0  1.0  1.0  1.0  1.0  2.0  2.0  2.0  2.0  3.0  3.0  3.0  3.0
	  0.0  1.0  2.0  3.0  0.0  1.0  2.0  3.0  0.0  1.0  2.0  3.0  0.0  1.0  2.0  3.0]
	# output  
	 2×16 Array{Float64,2}: ...

	julia> EW = 
	[[1, 2],[2, 3],[3, 4],[5, 6],[6, 7],[7, 8],[9, 10],[10, 11],[11, 12],[13, 14],
	 [14, 15],[15, 16],[1, 5],[2, 6],[3, 7],[4, 8],[5, 9],[6, 10],[7, 11],[8, 12],
	 [9, 13],[10, 14],[11, 15],[12, 16]]
	# output  
	24-element Array{Array{Int64,1},1}: ...

	julia> V,bases,coboundaries = chaincomplex(W,EW)

	julia> bases[1]	# edges
	24-element Array{Array{Int64,1},1}: ...
	
	julia> bases[2] # faces -- previously unknown !!
	9-element Array{Array{Int64,1},1}: ...

	julia> coboundaries[1] # coboundary_1 
	24×16 SparseMatrixCSC{Int8,Int64} with 48 stored entries: ...
	
	julia> full(coboundaries[2]) # coboundary_1: faces as oriented 1-cycles of edges
	9×24 Array{Int8,2}:
	 -1  0  0  1  0  0  0  0  0  0  0  0  1 -1  0  0  0  0  0  0  0  0  0  0
	  0 -1  0  0  1  0  0  0  0  0  0  0  0  1 -1  0  0  0  0  0  0  0  0  0
	  0  0 -1  0  0  1  0  0  0  0  0  0  0  0  1 -1  0  0  0  0  0  0  0  0
	  0  0  0 -1  0  0  1  0  0  0  0  0  0  0  0  0  1 -1  0  0  0  0  0  0
	  0  0  0  0 -1  0  0  1  0  0  0  0  0  0  0  0  0  1 -1  0  0  0  0  0
	  0  0  0  0  0 -1  0  0  1  0  0  0  0  0  0  0  0  0  1 -1  0  0  0  0
	  0  0  0  0  0  0  0 -1  0  0  1  0  0  0  0  0  0  0  0  0  0  1 -1  0
	  0  0  0  0  0  0 -1  0  0  1  0  0  0  0  0  0  0  0  0  0  1 -1  0  0
	  0  0  0  0  0  0  0  0 -1  0  0  1  0  0  0  0  0  0  0  0  0  0  1 -1
	```
	"""
   function chaincomplex( W, EW )
       V = W'
       EV = LARLIB.boundary_1(EW)'
       V,cscEV,cscFE = LARLIB.planar_arrangement(V,EV)
       ne,nv = size(cscEV)
       nf = size(cscFE,1)
       EV = [findn(cscEV[e,:]) for e=1:ne]
       FV = [collect(Set(vcat([EV[e] for e in findn(cscFE[f,:])]...)))  for f=1:nf]
       function ord(cells)
           return [sort(cell) for cell in cells]
       end
       temp = copy(cscEV')
       for k=1:size(temp,2)
           h = findn(temp[:,k])[1]
           temp[h,k] = -1
       end    
       cscEV = temp'
       bases, coboundaries = (ord(EV),ord(FV)), (cscEV,cscFE)
       return V',bases,coboundaries
   end

	"""
		chaincomplex( W::Points, FW::Cells, EW::Cells )
			::Tuple{ Array{Cells,1}, Array{ChainOp,1} }
	
	Chain 3-complex construction from bases of 2- and 1-cells. 
	
	From the minimal input, construct the whole
	two-dimensional chain complex, i.e. the bases for linear spaces C_1 and 
	C_2 of 1-chains and  2-chains, and the signed coboundary operators from 
	C_0 to C_1  and from C_1 to C_2.
	
	# Example
	```julia
	julia> cube_1 = ([0 0 0 0 1 1 1 1; 0 0 1 1 0 0 1 1; 0 1 0 1 0 1 0 1], 
	[[1,2,3,4],[5,6,7,8],[1,2,5,6],[3,4,7,8],[1,3,5,7],[2,4,6,8]], 
	[[1,2],[3,4],[5,6],[7,8],[1,3],[2,4],[5,7],[6,8],[1,5],[2,6],[3,7],[4,8]] )
	
	julia> cube_2 = LARLIB.Struct([LARLIB.t(0,0,0.5), LARLIB.r(0,0,pi/3), cube_1])
	
	julia> V,FV,EV = LARLIB.struct2lar(LARLIB.Struct([ cube_1, cube_2 ]))
	
	julia> V,bases,coboundaries = LARLIB.chaincomplex(V,FV,EV)
	
	julia> (EV, FV, CV), (cscEV, cscFE, cscCF) = bases,coboundaries

	julia> FV # bases[2]
	18-element Array{Array{Int64,1},1}:
	 [1, 3, 4, 6]            
	 [2, 3, 5, 6]            
	 [7, 8, 9, 10]           
	 [1, 2, 3, 7, 8]         
	 [4, 6, 9, 10, 11, 12]   
	 [5, 6, 11, 12]          
	 [1, 4, 7, 9]            
	 [2, 5, 11, 13]          
	 [2, 8, 10, 11, 13]      
	 [2, 3, 14, 15, 16]      
	 [11, 12, 13, 17]        
	 [11, 12, 13, 18, 19, 20]
	 [2, 3, 13, 17]          
	 [2, 13, 14, 18]         
	 [15, 16, 19, 20]        
	 [3, 6, 12, 15, 19]      
	 [3, 6, 12, 17]          
	 [14, 16, 18, 20]        

	julia> CV # bases[3]
	3-element Array{Array{Int64,1},1}:
	 [2, 3, 5, 6, 11, 12, 13, 14, 15, 16, 18, 19, 20]
	 [2, 3, 5, 6, 11, 12, 13, 17]                    
	 [1, 2, 3, 4, 6, 7, 8, 9, 10, 11, 12, 13, 17]    
	 
	julia> cscEV # coboundaries[1]
	34×20 SparseMatrixCSC{Int8,Int64} with 68 stored entries: ...

	julia> cscFE # coboundaries[2]
	18×34 SparseMatrixCSC{Int8,Int64} with 80 stored entries: ...
	
	julia> cscCF # coboundaries[3]
	4×18 SparseMatrixCSC{Int8,Int64} with 36 stored entries: ...
	```	
	"""
   function chaincomplex(W,FW,EW)
       V = W'
       EV = LARLIB.buildEV(EW)
       FE = LARLIB.coboundary_1(FW,EW)
       V,cscEV,cscFE,cscCF = LARLIB.spatial_arrangement(V,EV,FE)
       ne,nv = size(cscEV)
       nf = size(cscFE,1)
       nc = size(cscCF,1)
       EV = [findn(cscEV[e,:]) for e=1:ne]
       FV = [collect(Set(vcat([EV[e] for e in findn(cscFE[f,:])]...)))  for f=1:nf]
       CV = [collect(Set(vcat([FV[f] for f in findn(cscCF[c,:])]...)))  for c=2:nc]
       function ord(cells)
           return [sort(cell) for cell in cells]
       end
       temp = copy(cscEV')
       for k=1:size(temp,2)
           h = findn(temp[:,k])[1]
           temp[h,k] = -1
       end    
       cscEV = temp'
       bases, coboundaries = (ord(EV),ord(FV),ord(CV)), (cscEV,cscFE,cscCF)
       return V',bases,coboundaries
   end

   
   # Collect LAR models in a single LAR model
   function collection2model(collection)
      W,FW,EW = collection[1]
      shiftV = size(W,2)
      for k=2:length(collection)
         V,FV,EV = collection[k]
         W = [W V]
         FW = [FW; FV + shiftV]
         EW = [EW; EV + shiftV]
         shiftV = size(W,2)
      end
      return W,FW,EW
   end
   
   
   
	"""
		facetriangulation(V::Points, FV::Cells, EV::Cells, cscFE::ChainOp, cscCF::ChainOp)

	Triangulation of a single facet of a 3-complex.
	
	# Example
	```julia
	julia> cube_1 = ([0 0 0 0 1 1 1 1; 0 0 1 1 0 0 1 1; 0 1 0 1 0 1 0 1], 
	[[1,2,3,4],[5,6,7,8],[1,2,5,6],[3,4,7,8],[1,3,5,7],[2,4,6,8]], 
	[[1,2],[3,4],[5,6],[7,8],[1,3],[2,4],[5,7],[6,8],[1,5],[2,6],[3,7],[4,8]] )
	
	julia> cube_2 = LARLIB.Struct([LARLIB.t(0,0,0.5), LARLIB.r(0,0,pi/3), cube_1])
	
	julia> W,FW,EW = LARLIB.struct2lar(LARLIB.Struct([ cube_1, cube_2 ]))

	julia> V,(EV,FV,EV),(cscEV,cscFE,cscCF) = LARLIB.chaincomplex(W,FW,EW)
	```	
	"""
   function facetriangulation(V,FV,EV,cscFE,cscCF)
      function facetrias(f)
         vs = [V[:,v] for v in FV[f]]
         vs_indices = [v for v in FV[f]]
         vdict = Dict([(i,index) for (i,index) in enumerate(vs_indices)])
         dictv = Dict([(index,i) for (i,index) in enumerate(vs_indices)])
         es = findn(cscFE[f,:])
      
         vts = [v-vs[1] for v in vs]
      
         v1 = vts[2]
         v2 = vts[3]
         v3 = cross(v1,v2)
         err, i = 1e-8, 1
         while norm(v3) < err
            v2 = vts[3+i]
            i += 1
            v3 = cross(v1,v2)
         end   
      
         M = [v1 v2 v3]
   
         vs_2D = hcat([(inv(M)*v)[1:2] for v in vts]...)'
         pointdict = Dict([(vs_2D[k,:],k) for k=1:size(vs_2D,1)])
         edges = hcat([[dictv[v] for v in EV[e]]  for e in es]...)'
      
         trias = TRIANGLE.constrained_triangulation_vertices(
            vs_2D, collect(1:length(vs)), edges)
   
         triangles = [[pointdict[t[1,:]],pointdict[t[2,:]],pointdict[t[3,:]]] 
            for t in trias]
         mktriangles = [[vdict[t[1]],vdict[t[2]],vdict[t[3]]] for t in triangles]
         return mktriangles
      end
      return facetrias
   end
   
   # Triangulation of the 2-skeleton
	"""

	"""
   function triangulate(cf,V,FV,EV,cscFE,cscCF)
      mktriangles = facetriangulation(V,FV,EV,cscFE,cscCF)
      TV = Array{Int64,1}[]
      for (f,sign) in zip(cf[1],cf[2])
         triangles = mktriangles(f)
         if sign == 1
            append!(TV,triangles )
         elseif sign == -1
            append!(TV,[[t[2],t[1],t[3]] for t in triangles] )
         end
      end
      return TV
   end
   
   # Map 3-cells to local bases
	"""

	"""
   function map_3cells_to_localbases(V,CV,FV,EV,cscCF,cscFE)
      local3cells = []
      for c=1:length(CV)
         cf = findnz(cscCF[c+1,:])
         tv = triangulate(cf,V,FV,EV,cscFE,cscCF)
         vs = sort(collect(Set(hcat(tv...))))
         vsdict = Dict([(v,k) for (k,v) in enumerate(vs)])
         tvs = [[vsdict[t[1]],vsdict[t[2]],vsdict[t[3]]] for t in tv]
         v = hcat([V[:,w] for w in vs]...)
         cell = [v,tvs]
         append!(local3cells,[cell])
      end
      return local3cells
   end
   