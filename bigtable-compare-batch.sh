#!/usr/bin/env bash
# performance:
# n-standard-16 128memory
# 10 million blocks compare
# per_batch_slots=1000000
# no_batch=10

## default bigtable
#bigtable_def_cred=$HOME/gc-id/devnet-warehouse-worker.json
#bigtable_std_cred=$HOME/gc-id/development-warehouse-worker.json
 bigtable_def_cred=$HOME/gc-id/development-warehouse-worker.json
 bigtable_std_cred=$HOME/gc-id/devnet-warehouse-worker.json
## export default bigtable to GOOGLE_APPLICATION_CREDENTIALS where ledger tool read from
export GOOGLE_APPLICATION_CREDENTIALS=$bigtable_def_cred
## credential path for a standard bigtable
DEVELOPMENT_START=27198138
DEVNET_START=28356291

per_batch_slots=100000
start_slot=$DEVNET_START
no_batch=1000

## output
remove_output=true
filepath=output.txt

if [[ remove_output ]];then
    rm $filepath
fi

for i in $(seq 1 $no_batch)
do
    batch_ret=$($HOME/wks_solana/ledger-tool bigtable compare-blocks $start_slot $per_batch_slots $bigtable_std_cred)
    missing_blocks=$(echo $batch_ret | jq --raw-output '.missing_blocks | .[]')
    arr=$(echo $batch_ret | jq '.last_block_std, .count_def, .count_std')
    last_block_std=$(echo $arr | cut -d ' ' -f 1)
    count_std=$(echo $arr | cut -d ' ' -f 3)
    echo "count_std=$count_std last_block_std=$last_block_std"
    echo $missing_blocks >> $filepath
    if [[ $last_block_std < 0 ||  $count_std < $per_batch_slots ]];then  # end of standard block array
        echo "end of standard slots"
        break
    fi
    start_slot=$((last_block_std+1))
done

#echo $batch_ret | jq .
