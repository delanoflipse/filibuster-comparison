iterations=${N:-30}
result_tag=$1:

run_n_benchmark() {
    local benchmark_id=$1
    local test_name=$2
    local base_tag=${3:-$result_tag}

    for ((i=1; i<=iterations; i++)); do
        test_tag=${test_name//./_}
        iteration_tag="${base_tag}${test_tag}${i}"
        
        build_before=$(( i == 0 ? 1 : 0 ))
        skip_restart=$(( i > 1 ? 1 : 0 ))
        if [ "$i" -eq "$iterations" ]; then
            stop_after=1
        else
            stop_after=0
        fi

        echo "Running ${benchmark_id} benchmark (iteration $i of $iterations) (tag: $iteration_tag)"
        TAG=$iteration_tag SKIP_RESTART=$skip_restart BUILD_BEFORE=$build_before STOP_AFTER=$stop_after ./run_experiment.sh ${benchmark_id} ${test_name}
    done
}

trap "exit" INT


run_n_benchmark cinema-1 
run_n_benchmark cinema-2
run_n_benchmark cinema-3
run_n_benchmark cinema-4
run_n_benchmark cinema-5
run_n_benchmark cinema-6
run_n_benchmark cinema-7
run_n_benchmark cinema-8

run_n_benchmark audible
run_n_benchmark expedia
run_n_benchmark mailchimp test_get_url_random.py
run_n_benchmark mailchimp test_get_url.py
run_n_benchmark netflix
export NETFLIX_FAULTS=1
run_n_benchmark netflix test_get_homepage.py faults