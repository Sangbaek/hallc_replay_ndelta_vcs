#!/bin/bash
# submit_replay.sh
# Usage: ./submit_replay.sh <run_number>

runnum=$1
nev=-1
jobdir="SLURM/jobs"
logdir="/volatile/hallc/alphaE/ndelta_vcs2/calib/SLURM/logs"

if [ -z "$runnum" ]; then
    echo "Usage: $0 <run_number>"
    exit 1
fi

if (( runnum > 26561 )); then
    prefix="vcs2_production"
else
    prefix="ndelta_production"
fi

mkdir -p ROOTfiles "$jobdir" "$logdir"

# Count existing segments (check raw/ then cache/)
maxseg=0
for f in raw/${prefix}_${runnum}.dat.* cache/${prefix}_${runnum}.dat.*; do
    [ -e "$f" ] || continue
    seg="${f##*.}"
    if (( seg + 1 > maxseg )); then
        maxseg=$((seg + 1))
    fi
done

if (( maxseg == 0 )); then
    echo "No segment files found for run $runnum"
    exit 1
fi

echo "Found $maxseg segments for run $runnum (prefix=$prefix)"

arrayfile="${jobdir}/replay_array_${runnum}.slurm"
mergefile="${jobdir}/merge_${runnum}.slurm"

# --- Array job file ---
cat > "$arrayfile" <<EOF
#!/bin/bash
#SBATCH --account=hallc
#SBATCH --partition=production
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=16G
#SBATCH --job-name=replay_${runnum}
#SBATCH --time=24:00:00
#SBATCH --gres=disk:1G
#SBATCH --array=0-$((maxseg-1))
#SBATCH --output=${logdir}/replay_${runnum}_%a.out
#SBATCH --error=${logdir}/replay_${runnum}_%a.err

seg=\$SLURM_ARRAY_TASK_ID

cd /work/hallc/alphaE/apps
source setup.sh
cd hallc_replay_ndelta_vcs

rawfile="raw/${prefix}_${runnum}.dat.\${seg}"
if [ ! -f "\$rawfile" ]; then
    rawfile="cache/${prefix}_${runnum}.dat.\${seg}"
fi

if [ ! -f "\$rawfile" ]; then
    echo "No raw file for segment \$seg (\$rawfile)"
    exit 1
fi

echo "Running segment \$seg (run ${runnum}) on \$(hostname)"

cmd="SCRIPTS/COIN/PRODUCTION/replay_production_coin_pElec_hProt.C(${runnum},${nev},\${seg})"
hcana -l -q "\$cmd"

outfile="ROOTfiles/coin_replay_production_${runnum}_${nev}_\${seg}.root"
if [ ! -f "\$outfile" ]; then
    echo "ERROR: expected output \$outfile not found"
    exit 1
fi
EOF

# --- Merge job file ---
cat > "$mergefile" <<EOF
#!/bin/bash
#SBATCH --account=hallc
#SBATCH --partition=production
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=16G
#SBATCH --job-name=merge_${runnum}
#SBATCH --time=24:00:00
#SBATCH --gres=disk:4G
#SBATCH --output=${logdir}/merge_${runnum}.out
#SBATCH --error=${logdir}/merge_${runnum}.err

cd /work/hallc/alphaE/apps
source setup.sh
cd hallc_replay_ndelta_vcs

rootfiles=()
for ((seg=0; seg<${maxseg}; seg++)); do
    f="ROOTfiles/coin_replay_production_${runnum}_${nev}_\${seg}.root"
    if [ -f "\$f" ]; then
        rootfiles+=("\$f")
    else
        echo "WARNING: missing \$f"
    fi
done

if [ \${#rootfiles[@]} -eq 0 ]; then
    echo "No files to merge"
    exit 1
fi

merged="ROOTfiles/coin_replay_production_${runnum}_${nev}_all.root"
echo "Merging \${#rootfiles[@]} files into \$merged"

if hadd -f "\$merged" "\${rootfiles[@]}"; then
    echo "Merge successful"
    rm -f "\${rootfiles[@]}"
else
    echo "Merge failed, keeping segment files"
    exit 1
fi
EOF

chmod +x "$arrayfile" "$mergefile"

echo "Created:"
echo "  $arrayfile"
echo "  $mergefile"
echo ""
echo "To submit by hand:"
echo "sbatch  $arrayfile"
echo "after the array job is finished"
echo "sbatch  $mergefile"
