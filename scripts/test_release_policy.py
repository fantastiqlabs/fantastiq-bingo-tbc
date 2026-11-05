#!/usr/bin/env python3
"""Guard against publishing addon releases on ordinary main merges."""

import re
from pathlib import Path


release_workflow = Path(".github/workflows/release-main.yml").read_text(encoding="utf-8")
events = re.search(r"(?ms)^on:\s*\n(.*?)(?=^permissions:)", release_workflow)
assert events, "release workflow has no recognizable event block"
event_block = events.group(1)
assert re.search(r"(?m)^  workflow_dispatch:", event_block), "manual release dispatch must remain available"
assert not re.search(r"(?m)^  (?:push|pull_request):", event_block), "ordinary pushes and PRs must not publish"
assert re.search(
    r"(?ms)^      publish_release:\s*\n(?:(?!^      \w).)*?^        type: boolean\s*\n"
    r"(?:(?!^      \w).)*?^        default: false\s*$",
    event_block,
), "dispatch must use an explicit, false-by-default publish checkbox"
assert re.search(
    r"(?m)^    if: github\.ref == 'refs/heads/main' && inputs\.publish_release\s*$",
    release_workflow,
), "release job must be gated to main and explicit publish intent"

ci_workflow = Path(".github/workflows/ci.yml").read_text(encoding="utf-8")
assert re.search(
    r"(?ms)^on:\s*\n(?:(?!^permissions:).)*^  push:\s*\n"
    r"(?:(?!^permissions:).)*^    branches: \[main\]",
    ci_workflow,
), "main merges must keep normal CI validation enabled"
assert 'python3 scripts/package.py --target forever --output dist' in ci_workflow, "Forever must retain its separate archive build"
assert 'python3 scripts/package.py --output dist' in ci_workflow, "TBC must retain its separate archive build"

print("Release policy passed: normal merges validate/build; only an explicit main dispatch can publish.")
