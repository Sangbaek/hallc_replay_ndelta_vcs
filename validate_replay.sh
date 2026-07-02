#!/bin/bash
# validate_replay.sh
# Usage: ./validate_replay.sh <run_number>

runnum=$1
nev=-1
logdir="/volatile/hallc/alphaE/ndelta_vcs2/calib/SLURM/logs"
errors=0

if [ -z "$runnum" ]; then
    echo "Usage: $0 <run_number>"
    exit 1
fi

if (( runnum > 26561 )); then
    prefix="vcs2_production"
else
    prefix="ndelta_production"
fi

# Count segments
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

# Expected .err content (exact)
read -r -d '' expected_err <<'EXPECTED'
Info in <THaCrateMap::init(tloc)>: Opened database file MAPS/db_cratemap.dat
Info in <THaCrateMap::init(tloc)>: Opened database file MAPS/db_cratemap.dat
Error in <THcFormula::Compile>:  Bad numerical expression : "P.EDTM.scalerCutRate"
Error in <THcFormula::Compile>:  Bad numerical expression : "P.EDTM.scalerCutRate"
Error in <THcFormula::Compile>:  Bad numerical expression : "H.EDTM.scalerCutRate"
Error in <THcFormula::Compile>:  Bad numerical expression : "H.EDTM.scalerCutRate"
EXPECTED

echo "=== Validation for run ${runnum} (${maxseg} segments) ==="

# Check 1: ROOT files
echo "--- Checking ROOT files ---"
rootcount=0
for ((seg=0; seg<maxseg; seg++)); do
    f="ROOTfiles/coin_replay_production_${runnum}_${nev}_${seg}.root"
    if [ -f "$f" ]; then
        ((rootcount++))
    else
        echo "BAD: $f"
        ((errors++))
    fi
done
echo "${rootcount}/${maxseg} ROOT files present"

# Check 2: err file content
echo "--- Checking error logs ---"
for ((seg=0; seg<maxseg; seg++)); do
    errfile="${logdir}/replay_${runnum}_${seg}.err"
    if [ ! -f "$errfile" ]; then
        echo "BAD err log: $errfile"
        ((errors++))
        continue
    fi
    actual=$(cat "$errfile")
    if [ "$actual" = "$expected_err" ]; then
        echo "OK  [seg ${seg}]"
    else
        echo "BAD [seg ${seg}]: unexpected content in $errfile"
        echo "    --- diff ---"
        diff <(echo "$expected_err") <(echo "$actual") | sed 's/^/    /'
        ((errors++))
    fi
done

echo ""
if (( errors > 0 )); then
    echo "${runnum} Validation FAILED with ${errors} error(s)."
    exit 1
fi

echo "Validation PASSED. Safe to submit merge job:"
echo "  sbatch SLURM/jobs/merge_${runnum}.slurm"
