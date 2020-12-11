using DataFrames

# filename = "/home/gregorylemieux/Work/Issues/383/deciduous-griddedruns/cesm.log.1805694.chadmin1.ib0.cheyenne.ucar.edu.200417-103849"
# filename = "/home/gregorylemieux/Work/Issues/383/deciduous-griddedruns/cesm.log.1851933.chadmin1.ib0.cheyenne.ucar.edu.200420-102252"
# filename = "/home/gregorylemieux/Work/Issues/383/deciduous-griddedruns/cesm.log.1855695.chadmin1.ib0.cheyenne.ucar.edu.200420-130249"
# filename = "/home/gregorylemieux/Work/Issues/383/deciduous-griddedruns/cesm.log.1877502.chadmin1.ib0.cheyenne.ucar.edu.200421-125647"
filename = "/home/gregorylemieux/Work/Issues/383/deciduous-griddedruns/cesm.log.1927093.chadmin1.ib0.cheyenne.ucar.edu.200423-153202"
# filename = "/home/gregorylemieux/Work/Issues/383/deciduous-griddedruns/cesm.log.1937038.chadmin1.ib0.cheyenne.ucar.edu.200424-103859"

# Open the file
f = open(filename)

# Read through each line and pull out the unique threadnumbers
A = Vector{Int64}() # Initialize
for line in eachline(f)
    threadnum = parse(Int64,split(line,":")[1]) # Parse the line for the thread number
    if !(in(threadnum,A)) # If not in the array add it
        push!(A,threadnum)
    end
end

# Close the file
close(f)

# Check all entries are unique
println(A == unique(A))

# Check that the thread numbers are sequential
println(sort!(A) == Array(0:maximum(A)))

# Set the known strings we are interested in
string_canopy = "Starting canopy trim"
string_cohort = "Current cohort"
string_laimem = "Starting laimemory"
string_leafm = "Starting leaf biomass"
string_treelai = "currentCohort%treelai"
string_season = "EDPftvarcon_inst%season_decid"
string_stress = "EDPftvarcon_inst%stress_decid"
string_evergreen = "EDPftvarcon_inst%evergreen"
string_optimum = "OPTIMUM_LAIMEM"
string_cumulative = "CUMULATIVE LAI"
string_trimopt = "OPTIMUM TRIM"
string_nnu = "nnu_clai_a"
string_nv = "currentCohort%nv"
string_cstatus = "currentSite%cstatus"
string_dstatus = "currentSite%dstatus"
string_coh = "currentCohort%status_coh"
string_end = "End of cohort info"

nll = 4

# Initialize vectors
thread_vec = Vector{Int64}()
laimem_vec = Vector{Float64}()
treelai_vec = Vector{Float64}()
leafmass_vec = Vector{Float64}()
leafmass_vec = Vector{Float64}()
seasonal_vec = Vector{Float64}()
stress_vec = Vector{Float64}()
evergreen_vec = Vector{Float64}()
leafonoff_vec = Vector{Int64}()
cstatus_vec = Vector{Int64}()
dstatus_vec = Vector{Int64}()
nnu_vec = Vector{Float64}()

totallaicount = 0;

f = open(filename)

# Leaf status check loop
totallaicount = 0;
for t in A
#     println(t)
    
# Try implementing regex instead of parse
#     f = open(filename) # Open the file`
    
    # Iterate through file
    for line in eachline(f)
        
        linesplit = split(line,":") # Split into array of strings
        threadnum = parse(Int64,linesplit[1]) # Parse the line for the thread number
        
        # Make sure the line format is threadnum:string:val
        if threadnum == t && length(linesplit) == 3 && isempty(findall(isempty,linesplit))
            
            if strip(linesplit[2]) == string_laimem
                totallaicount += 1  # Count up the total laimemory loops
                push!(thread_vec,threadnum)
                push!(laimem_vec,parse(Float64,strip(linesplit[3])))
                
            # Next is the leaf biomass
            elseif strip(linesplit[2]) == string_leafm
                push!(leafmass_vec,parse(Float64,strip(linesplit[3])))

            # Next is the leaf biomass
            elseif strip(linesplit[2]) == string_treelai
                push!(treelai_vec,parse(Float64,strip(linesplit[3])))
                    
            # Next three lines should be the deciduous/evergreen states
            elseif strip(linesplit[2]) == string_season
                push!(seasonal_vec,parse(Float64,strip(linesplit[3])))
            elseif strip(linesplit[2]) == string_stress
                push!(stress_vec,parse(Float64,strip(linesplit[3])))
            elseif strip(linesplit[2]) == string_evergreen
                push!(evergreen_vec,parse(Float64,strip(linesplit[3])))
                
            # Next is the leaf on/off status
            elseif strip(linesplit[2]) == string_coh
                push!(leafonoff_vec,parse(Int64,strip(linesplit[3]))) # leaves_off = 1, leaves_on = 2
                
            # Next is the cold and drought statuses
            elseif strip(linesplit[2]) == string_cstatus
                # Cold Leaf Off = 0 or 1, Cold Leaf On = 2
                push!(cstatus_vec,parse(Int64,strip(linesplit[3]))) # phen_cstat_nevercold = 0, phen_cstat_iscold = 1, phen_cstat_notcold = 2
            elseif strip(linesplit[2]) == string_dstatus
                # Drought Leaf On = 2 or 3, Drought Leaf Off = 0 or 1
                push!(dstatus_vec,parse(Int64,strip(linesplit[3]))) # phen_dstat_timeon = 2, phen_dstat_moiston = 3, phen_dstat_moistoff = 0, phen_dstat_timeoff = 1
            elseif strip(linesplit[2]) == string_nnu
                # Determines if optimization routine will be entered
                push!(nnu_vec,parse(Float64,strip(linesplit[3])))
            end # string match
        end # thread match
    end # eachline
    if eof(f)
        seekstart(f)
    end
#     close(f) # Close the file
end            

close(f)

df = DataFrame(thread=thread_vec,laimemory=laimem_vec,
               leafmass=leafmass_vec,treelai=treelai_vec,
               seasonal_decid=seasonal_vec,stress_decid=stress_vec,evergreen_decid=evergreen_vec,
               leafonoff=leafonoff_vec,cold=cstatus_vec,drought=dstatus_vec,nnu=nnu_vec);

decid_states = groupby(df,[:stress_decid,:seasonal_decid,:evergreen_decid]);

decid_states[1][1,:]

decid_states[2][1,:]

decid_states[3][1,:]

df.laimem_zero = df.laimemory .== 0;

laimem_group = groupby(df,:laimem_zero);

nrows_laizero = size(laimem_group[1])[1]

describe(laimem_group[1])

describe(laimem_group[2])

stress_laimem_group = groupby(laimem_group[1],:stress_decid);

describe(stress_laimem_group[2])

nrows_decid = [size(stress_laimem_group[2])[1]]

seasonal_laimem_group = groupby(laimem_group[1],:seasonal_decid);

describe(seasonal_laimem_group[1])

push!(nrows_decid,size(seasonal_laimem_group[1])[1])

sum(nrows_decid)

evergreen_laimem_group = groupby(laimem_group[1],:evergreen_decid);

nrows_evergreen = size(evergreen_laimem_group[2])[1]

describe(evergreen_laimem_group[2])

sum(nrows_decid)+nrows_evergreen == nrows_laizero

nrow(laimem_group[2])

df.nnu_gtone = df.nnu .> 1;

nnu_group = groupby(df,:nnu_gtone);

describe(nnu_group[1])

describe(nnu_group[2])

nrows_nonopt = nrow(nnu_group[1])

nrows_opt = nrow(nnu_group[2])

nnu_laimemzero_group = groupby(nnu_group[2],:laimem_zero)

describe(nnu_laimemzero_group[1])
