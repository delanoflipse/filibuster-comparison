#!/bin/bash
project_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
corpus_path=$(realpath "${CORPUS_PATH:-"$project_path/../corpus"}")
benchmark_id=$1
result_tag=${TAG:-default}
run_id=$(date +%Y_%m_%d__%H_%M_%S)
echo Project path: $project_path
echo Corpus path: $corpus_path

result_dir="$project_path/results/$benchmark_id/$result_tag"
echo Output directory: $result_dir
mkdir -p "$result_dir"

benchmark_dir=$(realpath "$corpus_path/$benchmark_id")
echo Benchmark directory: $benchmark_dir

if [ -z "$2" ]; then
    functiona_test_file=$(find "$benchmark_dir/functional" -type f ! -name "__init__.py" -exec basename {} \;)
else
    functiona_test_file=$2
fi
echo Functional test: $functiona_test_file

# Build the services
cd $benchmark_dir; make docker-build

# Start the services
cd $project_path

# flask_debug=${FLASK_DEBUG:-""}
# debug=${DEBUG:-""}
if [ -z $FLASK_DEBUG ]; then
    export FLASK_DEBUG=$FLASK_DEBUG
fi

if [ -z $DEBUG ]; then
    export DEBUG=$DEBUG
fi

# Start the services

if [ "${SKIP_RESTART:-0}" != "1" ]; then
   AWS_ACCOUNT_ID=194095331551 REGION=us-east-2 docker compose -f "$benchmark_dir/docker-compose.yml" up -d --remove-orphans --force-recreate
fi

# Run the experiment
# export PRINT_RESPONSES=1

poetry run python filibuster_cli.py \
    --functional-test="python $benchmark_dir/functional/$functiona_test_file" \
    --analysis-file="comparison-analysis.json" \
    2>&1 | tee "$result_dir/filibuster.log"

# Stop the services
if [ "${STOP_AFTER:-1}" == "1" ]; then
    AWS_ACCOUNT_ID=194095331551 REGION=us-east-2 docker compose -f "$benchmark_dir/docker-compose.yml" down
fi
