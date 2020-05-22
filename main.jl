cd("C:\\Users\\Ylann Rouzaire\\.julia\\environments\\ML_env")
using Pkg; Pkg.activate("."); Pkg.instantiate();
cd("D:\\Documents\\Ecole\\EPFL\\Internship_2019_ML\\Kernel Classification SVM")

parallelized_over = "Δ" # change accordingly [PP for i in eachindex(...)] and addprocs
Δ = [0.005,0.01,0.02,0.03,0.05,0.1]
PP = unique(Int.(round.(10.0 .^range(log10(20),stop=log10(1E4),length=50))))
dimensions = [2,3,10]
M = 20

using Distributed
addprocs(length(Δ))
@everywhere include("function_definitions.jl")
@everywhere using SpecialFunctions,LinearAlgebra,Distributions,PyCall,Dates,JLD
@everywhere SV = pyimport("sklearn.svm")

@time Run(parallelized_over,[PP for i in eachindex(Δ)],Δ,[dimensions for i in eachindex(Δ)],[M for i in eachindex(Δ)]) ## parallelized_over = "Δ"
# @time Run(parallelized_over,[PP for i in eachindex(dimensions)],[Δ for i in eachindex(dimensions)],dimensions,[M for i in eachindex(dimensions)]) ## parallelized_over = "dimensions"
JLD.save("Data\\Gaussian_Kernel\\parameters_"*string(Dates.day(now()))*".jld","PP", PP, "Δ", Δ, "dimensions", dimensions, "M", M,"parallelized_over",parallelized_over)
rmprocs(workers())
