#!/bin/bash

runnum=$1
maxseg=20
nev=-1
maxjobs=4

if [ -z "$runnum" ]; then
    echo "Usage: $0 <run_number>"
    exit 1
fi

mkdir -p ROOTfiles logs
rootfiles=()
jobcount=0

for ((seg=0; seg<maxseg; seg++)); do
    rawfile="raw/ndelta_production_${runnum}.dat.${seg}"
    outfile="ROOTfiles/coin_replay_production_${runnum}_${nev}_${seg}.root"

    if [ ! -f "$rawfile" ]; then
        echo "No raw file for segment $seg"
        break
    fi

    echo "Launching segment $seg"

    cmd="SCRIPTS/COIN/PRODUCTION/replay_production_coin_pElec_hProt.C(${runnum},${nev},${seg})"

    hcana -l -q "$cmd" > "logs/run_${runnum}_${seg}.log" 2>&1 &

    rootfiles+=("$outfile")
    ((jobcount++))

    # Wait after maxjobs are launched
    if (( jobcount >= maxjobs )); then
        echo "Waiting for current batch to finish..."
        wait
        jobcount=0
    fi
done

# Wait for any remaining jobs
wait
echo "All segment jobs completed"

# Merge all files
if [ ${#rootfiles[@]} -gt 0 ]; then
    merged="ROOTfiles/coin_replay_production_${runnum}_${nev}_all.root"
    echo "Merging ${#rootfiles[@]} files into $merged"

    if hadd -f "$merged" "${rootfiles[@]}"; then
        echo "Merge successful"

        # Optional cleanup
        echo "Deleting segment ROOT files"
        rm -f "${rootfiles[@]}"
    else
        echo "Merge failed, keeping segment files"
    fi
else
    echo "No files to merge"
fi
