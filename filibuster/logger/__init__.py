import os
import sys
from datetime import datetime


class BColors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

def get_timestamp():
    return datetime.now().strftime("%Y-%m-%d %H:%M:%S")

USE_COLOR = os.environ.get("USE_COLOR", "true").lower() == "true"

def log_string(tag: str, string: str):
    return get_timestamp() + " [FILIBUSTER] [" + tag + "]: " + string

def with_color(color, string):
    if USE_COLOR:
        return color + string + BColors.ENDC
    else:
        return string

def error(string):
    print(with_color(BColors.FAIL, log_string("FAIL", string)), file=sys.stderr, flush=True)

def warning(string):
    if os.environ.get("DEBUG", ""):
        print(with_color(BColors.WARNING, log_string("WARNING", string)), file=sys.stderr, flush=True)


def notice(string):
    if os.environ.get("DEBUG", ""):
        print(with_color(BColors.OKGREEN, log_string("NOTICE", string)), file=sys.stderr, flush=True)
    


def info(string):
    print(with_color(BColors.OKBLUE, log_string("INFO", string)), file=sys.stderr, flush=True)


def debug(string):
    if os.environ.get("DEBUG", ""):
        print(with_color(BColors.OKCYAN, log_string("DEBUG", string)), file=sys.stderr, flush=True)
