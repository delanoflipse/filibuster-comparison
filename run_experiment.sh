#!/bin/bash
project_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
corpus_path=$(realpath "${CORPUS_PATH:-"$project_path/../corpus"}")
benchmark_id=$1
result_tag=${2:+-$2}
run_id=$(date +%Y_%m_%d__%H_%M_%S)
echo Project path: $project_path
echo Corpus path: $corpus_path

result_dir="$project_path/results/$benchmark_id$result_tag"
echo Output directory: $result_dir
mkdir -p "$result_dir"

benchmark_dir=$(realpath "$corpus_path/$benchmark_id")
echo Benchmark directory: $benchmark_dir

functiona_test_file=$(find "$benchmark_dir/functional" -type f ! -name "__init__.py" -exec basename {} \;)
echo Functional test: $functiona_test_file

# Start the services
cd $benchmark_dir; make docker-build

cd $project_path
env_vars="FLASK_DEBUG=1 DEBUG=1 AWS_ACCOUNT_ID=194095331551 REGION=us-east-2"

# Start the services
$env_vars docker compose -f "$benchmark_dir/docker-compose.yml" up -d --remove-orphans --force-recreate

# Run the experiment
poetry shell
python filibuster_cli.py \
    --functional-test="python $benchmark_dir/functional/$functiona_test_file" \
    --analysis-file="comparison-analysis.json" \
2>&1 | tee "$result_dir/filibuster.log"

# Stop the services
$env_vars docker compose -f "$benchmark_dir/docker-compose.yml" down
