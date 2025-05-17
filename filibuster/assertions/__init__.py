import requests

from filibuster.logger import error

FILIBUSTER_HOST = "127.0.0.1"
FILIBUSTER_PORT = "5050"
TIMEOUT = 10

# Use a session, to reuse the same TCP connection for multiple requests.
s = requests

def was_fault_injected():
    uri = "http://{}:{}/filibuster/fault-injected".format(FILIBUSTER_HOST, FILIBUSTER_PORT)
    response = s.get(uri, timeout=TIMEOUT)

    if response.status_code == 200:
        response_json = response.json()
        return response_json['result']
    else:
        error("Returning false from was_fault_injected, could not contact Filibuster server.")
        return False


def was_fault_injected_on(service_name):
    uri = "http://{}:{}/filibuster/fault-injected/{}".format(FILIBUSTER_HOST, FILIBUSTER_PORT, service_name)
    response = s.get(uri, timeout=TIMEOUT)

    if response.status_code == 200:
        response_json = response.json()
        return response_json['result']
    else:
        error("Returning false from was_fault_injected_on, could not contact Filibuster server.")
        return False
