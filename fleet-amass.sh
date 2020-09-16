#!/usr/bin/env bash

set -e

cli_help(){
    echo "Usage: fleet-amass path/to/targets"
exit 1
}

analyze(){
    echo "Fleet scanning $1 ..."
    axiom-scan $1 -m=amass -config=amass.ini -o="$2/fleet-amass.txt"
}

if [ -z $1 ]; then
    cli_help
fi

TARGETS_DIR=$1

if [ ! -d "$TARGETS_DIR" ]; then
    echo "Directory '$TARGETS_DIR' does not exist"
    cli_help
fi

echo "Targets directory: $TARGETS_DIR"
echo "Targets found:"
echo "$(ls $TARGETS_DIR)"

cd $TARGETS_DIR

axiom-select 'recon*'

# Loop over targets
for target in *; do 
    [ -d $target ] || continue

    domains_file="$TARGETS_DIR/$target/domains.txt"
    if [ ! -f $domains_file ]; then
        echo "$domains_file not found, skipping..."
        continue
    fi

    # Run subdomain enumeration
    results_dir="$TARGETS_DIR/$target/fleet-scan"
    if [ ! -d $results_dir ]; then
        mkdir $results_dir
    fi
    amass_domains="$results_dir/amass_domains.txt"
    cp $domains_file $amass_domains
    analyze $amass_domains $results_dir
done

echo ""
echo "Done."
