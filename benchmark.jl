cd("C:\\Users\\Ylann Rouzaire\\.julia\\environments\\ML_env")
using Pkg; Pkg.activate("."); Pkg.instantiate();
# using Plots, SpecialFunctions, JLD, Dates,Distributed, LinearAlgebra, Distributions,MLJ
# pyplot() ; plot()
using SpecialFunctions,Distributed,LinearAlgebra,Distributions,PyCall
# @MLJ.load SVC pkg=LIBSVM
include("function_definitions.jl")

Δ0 = 0.01
Ptrain = Int(1E2)
Ptest = Int(1E6)
N = Ptrain + Ptest
dimension = 3
δ = Ptrain^(-1/dimension)

X = generate_X(Ptrain,Ptest,dimension,Δ0)
Y = generate_Y(X,Δ0)
Xtest,Ytest = extract_TestSet(X,Y,Ptest)
Xtrain,Ytrain = extract_TrainSet(X,Y,Ptrain)

# scatter([X[i][1] for i in 1:N],[X[i][2] for i in 1:N],[X[i][3] for i in 1:N],label=nothing,camera=(30,70))
# xlabel!("x")
# ylabel!("y")
# title!("Distribution with Margin Δ0 = 0.5")
# savefig("distrib_X.pdf")

## First SVM tests
svc_model = SVC(cost=1E10)
svc = machine(svc_model, MLJ.table(Xtrain), Ytrain)
fit!(svc)
Ypred = predict(svc, Xtest)
println("𝝐 = ",misclassification_rate(Ypred, Ytest))
G = Gram(Xtrain,1/2)
SVC(kernel="RadialBasis")

##
cd("C:\\Users\\Ylann Rouzaire\\.julia\\environments\\ML_env")
using Pkg; Pkg.activate("."); Pkg.instantiate();
cd("D:\\Documents\\Ecole\\EPFL\\Internship_2019_ML\\Kernel Classification SVM")

using SpecialFunctions,LinearAlgebra,Distributions,PyCall,Dates,JLD,Distributed
include("function_definitions.jl")
SV = pyimport("sklearn.svm")

PP = [10,20,30,50,100,200,300,500] ; Ptest = 1000
Δ = 0.0
d = 10
misclassification_error_matrix = zeros(length(PP))
# coeff_SV = []
PP = 50 ; Ptest = 100
# for i in eachindex(PP)
Ptrain = PP
X             = generate_X(Ptrain,Ptest,d,Δ)
Y             = generate_Y(X,Δ)
Xtest,Ytest   = extract_TestSet(X,Y,Ptest)
Xtrain,Ytrain = extract_TrainSet(X,Y,Ptrain)

clf = SV.SVC(C=1E10,kernel="precomputed",cache_size=800) # 800 MB allocated cache
GramTrain = Laplace_Kernel(Xtrain,Xtrain)
clf.fit(GramTrain, Ytrain)
if i == length(PP)
    # append!(coeff_SV,clf.dual_coef_)
    # println("#dual coeff min : ",minimum(abs.(clf.dual_coef_)))
    # # display(histogram(log10.(abs.(clf.dual_coef_')),yaxis=(:log10)))
    # display(histogram(abs.(clf.dual_coef_'),axis=(:log10)))
end
# println("#alpha bar : ")
println("#alpha bar : ",mean(abs.(clf.dual_coef_))," ± ",std(abs.(clf.dual_coef_)))
println("#SVind : ",X[clf.support_ .+ 1][1])
GramTest = Laplace_Kernel(Xtrain,Xtest)

misclassification_error_matrix = testerr(clf.predict(GramTest),Ytest)
# alpha_avg[i] = mean(abs.(clf.dual_coef_))
# alpha_std[i] = mean(std.(clf.dual_coef_))

# end # Ptrain
println(length(coeff_SV))
plot(box=true,xlabel="log10(SV coefficients)",ylabel="Count")
histogram!(log10.(abs.(coeff_SV)),yaxis=(:log10),label="")
savefig("Figures\\CoeffSV.pdf")

## Compute rc
sv = X[clf.support_ .+ 1]
svy = Bool.((generate_Y(sv) .+ 1)/2)
sv_plus = sv[svy]
sv_minus = sv[.!svy]

rc_plus  = [sort([norm(sv_plus[i]-sv_plus[j]) for j in eachindex(sv_plus)])[2] for i in eachindex(sv_plus)]
rc_minus = [sort([norm(sv_minus[i]-sv_minus[j]) for j in eachindex(sv_minus)])[2] for i in eachindex(sv_minus)]
rc = vcat(rc_plus,rc_minus)
println("+ : ",mean(rc_plus)," ± ",std(rc_plus))
println("- : ",mean(rc_minus)," ± ",std(rc_minus))
println("Both : ",mean(rc)," ± ",std(rc))


# ## G
# u = rand(100)
# G = Laplace_Kernel(u,u)
# GG = G^2
# invG = inv(G)
# un = invG*G
