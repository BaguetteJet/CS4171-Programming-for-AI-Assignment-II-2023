# CS4171 Project 2 2023
# Igor Kochanski [23358459]
using Pkg

Pkg.add("CairoMakie")
Pkg.add("CSV")
Pkg.add("DataFrames")
Pkg.add("Dates")
Pkg.add("Statisctics")

using CairoMakie
using CSV
using DataFrames
using Dates
using Statistics

# Part 1
windgen = CSV.read("wind-gen.csv", DataFrame)

datef = dateformat"dd U yyyy HH:MM"

data1 = DataFrame(
    DATE = Date.(windgen."DATE & TIME", datef),
    FORWIND = windgen." FORECAST WIND(MW)",
    ACCWIND = windgen."  ACTUAL WIND(MW)"
)

re = r"^[0-9]*$"
data1.ACCWIND = [occursin(re, val) ? parse(Int, val) : missing for val in data1.ACCWIND]

mondays1 = filter(row -> dayofweek(row.DATE) == 1, data1)
day1 = string.(unique(mondays1.DATE))
xval = 1:length(data1.DATE)

dayrow1(x) = findfirst(==(x), string.(data1.DATE))
step1 = dayrow1.(day1)

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
lines!(ax1, xval, data1.ACCWIND, color = :blue, label = "Actual")
lines!(ax1, xval, data1.FORWIND, color = :red, label = "Forecast")
axislegend(ax1)

save("wind-gen.png", fig1)

# PART 2
sysdem = CSV.read("system-demand.csv", DataFrame)

data2 = DataFrame(
    DATETIME = DateTime.(sysdem."DATE & TIME", datef),
    DEMAND = sysdem." ACTUAL DEMAND(MW)"
)

data2.DEMAND = [occursin(re, val) ? parse(Int, val) : missing for val in data2.DEMAND]
data2.DATETIME = floor.(DateTime.(data2.DATETIME), Dates.Hour)

data2 = combine(groupby(data2, :DATETIME), names(data2, Not(:DATETIME)) .=> mean, renamecols=false)

data3 = DataFrame(
    DATE = Date.(data2.DATETIME),
    TIME = Time.(data2.DATETIME),
    DEMAND = [ismissing(val) ? missing : floor(Int, val) for val in data2.DEMAND]
)

dataarray = Array(unstack(data3, :DATE, :TIME, :DEMAND)[!, 2:end])

mondays2 = filter(row -> dayofweek(row.DATE) == 1, data3)
day2 = string.(unique(mondays2.DATE))
time = string.(unique(data3.TIME))

dayrow2(x) = findfirst(==(x), string.(unique(data3.DATE)))
step2 = dayrow2.(day2)

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

function colourcheck(x)
    if ismissing(x)
        return :red
    elseif x < 5000
        return :white
    else 
        return :black
    end
end

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

save("system-demand-heatmap.png", fig2)