# CS4171 Project 2 2023
# Igor Kochanski [23358459]
using Pkg

Pkg.add("CairoMakie")
Pkg.add("CSV")
Pkg.add("DataFrames")
Pkg.add("Dates")
Pkg.add("Statistics")

print("CS4171 Project 2 2023\nby Igor Kochanski [23358459]\n")

println("⌛ Loading CairoMakie...")
using CairoMakie
println("✅ CairoMakie Loaded")

println("⌛ Loading CSV...")
using CSV
println("✅ CSV Loaded")

println("⌛ Loading DataFrames...")
using DataFrames
println("✅ DataFrames Loaded")

println("⌛ Loading Dates...")
using Dates
println("✅ Dates Loaded")

println("⌛ Loading Statistics...")
using Statistics
println("✅ Statistics Loaded")

println("✅ Imports Loaded")

# Part 1
println("PART 1")

println("⌛ Loading 'wind-gen.csv'...")
windgen = CSV.read("wind-gen.csv", DataFrame)
display(windgen)#
println("✅ 'wind-gen.csv' Loaded")#

datef = dateformat"dd U yyyy HH:MM"

println("⌛ Loading 'data1'...")
data1 = DataFrame(
    DATE = Date.(windgen."DATE & TIME", datef),
    FORWIND = windgen." FORECAST WIND(MW)",
    ACCWIND = windgen."  ACTUAL WIND(MW)"
)
display(data1)
println("✅ 'data1' Loaded")

println("⌛ Parsing 'data1'...")
re = r"^[0-9]*$"
data1.ACCWIND = [occursin(re, val) ? parse(Int, val) : missing for val in data1.ACCWIND]
display(data1)
println("✅ 'data1' Parsed")

println("⌛ Finding 'mondays1'...")
mondays1 = filter(row -> dayofweek(row.DATE) == 1, data1)
day1 = string.(unique(mondays1.DATE))
xval = 1:length(data1.DATE)
println("✅ 'mondays1' Found")

println("⌛ Finding 'mondays1' Step-Range...")
dayrow1(x) = findfirst(==(x), string.(data1.DATE))
step1 = dayrow1.(day1)
println("✅ 'mondays1' Step-Range Found")

println("⌛ Making 'fig1'...")
fig1 = Figure(resolution = (1500, 700), fontsize = 20);
ax1 = Axis(fig1[1, 1],
    xticks = (step1, day1),
    xticklabelalign = (:right, :center),
    xticklabelpad = 10,
    xlabel = "Date",
    xticklabelrotation = π / 6,
    ylabel = "Wind (MW)",
    title = "Wind Generation Graph 2023"
)
display(fig1)
println("✅ 'fig1' Made")

println("⌛ Graphing 'fig1'...")
lines!(ax1, xval, data1.ACCWIND, color = :blue, label = "Actual")
lines!(ax1, xval, data1.FORWIND, color = :red, label = "Forecast")
axislegend(ax1)
display(fig1)
println("✅ 'fig1' Graphed")

println("⌛ Saving 'fig1'...")
save("wind-genANO.png", fig1)
println("✅ 'fig1' Saved as 'wind-genANO.png'")

# PART 2
println("PART 2")

println("⌛ Loading 'system-demand.csv'...")
sysdem = CSV.read("system-demand.csv", DataFrame)
display(sysdem)
println("✅ 'system-demand.csv' Loaded")

println("⌛ Loading 'data2'...")
data2 = DataFrame(
    DATETIME = DateTime.(sysdem."DATE & TIME", datef),
    DEMAND = sysdem." ACTUAL DEMAND(MW)"
)
display(data2)
println("✅ 'data2' Loaded")

println("⌛ Parsing 'data2'...")
data2.DEMAND = [occursin(re, val) ? parse(Int, val) : missing for val in data2.DEMAND]
data2.DATETIME = floor.(DateTime.(data2.DATETIME), Dates.Hour)
display(data2)
println("✅ 'data2' Parsed")

println("⌛ Combining Mean 'data2'...")
data2 = combine(groupby(data2, :DATETIME), names(data2, Not(:DATETIME)) .=> mean, renamecols=false)
display(data2)
println("✅ 'data2' Mean Combined")

println("⌛ Loading 'data3'...")
data3 = DataFrame(
    DATE = Date.(data2.DATETIME),
    TIME = Time.(data2.DATETIME),
    DEMAND = [ismissing(val) ? missing : floor(Int, val) for val in data2.DEMAND]
)
display(data3)
println("✅ 'data3' Loaded")

println("⌛ Unstacking 'data3'...")
dataarray = Array(unstack(data3, :DATE, :TIME, :DEMAND)[!, 2:end])
display(dataarray)
println("✅ 'data3' Unstacked")

println("⌛ Finding 'mondays2'...")
mondays2 = filter(row -> dayofweek(row.DATE) == 1, data3)
day2 = string.(unique(mondays2.DATE))
time = string.(unique(data3.TIME))
println("✅ 'mondays2' Found")

println("⌛ Finding 'mondays2' Step-Range...")
dayrow2(x) = findfirst(==(x), string.(unique(data3.DATE)))
step2 = dayrow2.(day2)
println("✅ 'mondays2' Step-Range Found")

println("⌛ Making 'fig2'...")
fig2 = Figure(resolution = (1500, 1000), fontsize = 20)
ax2 = Axis(
    fig2[1, 1],
    xticks = (step2, day2),
    xticklabelalign = (:right, :center),
    xticklabelpad = 10,
    xticklabelrotation = π / 6,
    xlabel = "Date",
    yticks = (1:size(dataarray)[2], time),
    yticklabelalign = (:right, :center),
    ylabel = "Time",
    title = "System Demand Heatmap (MW) 2023"
)
hm = heatmap!(ax2, dataarray)
Colorbar(fig2[1, 2], hm)
display(fig2)
println("✅ 'fig2' Made")

println("⌛ Loading Function 'colourcheck'...")
function colourcheck(x)
    if ismissing(x)
        return :red
    elseif x < 5000
        return :white
    else 
        return :black
    end
end
println("✅ colourcheck Function Loaded")

println("⌛ Adding Text 'fig2'...")
colors = colourcheck.(dataarray)
for x in 1:size(dataarray)[1], y in 1:size(dataarray)[2]
text!(ax2,
    string.(dataarray)[x, y],
    position = (x, y),
    align = (:center, :center),
    color = colors[x, y],
    textsize = 12,
    )
end
display(fig2)
println("✅ 'fig2' Text Added")

println("⌛ Saving 'fig2' as 'system-demand-heatmapANO.png'...")
save("system-demand-heatmapANO.png", fig2)
println("✅ 'fig2' Saved as 'system-demand-heatmapANO.png'")
println("✅ DONE")