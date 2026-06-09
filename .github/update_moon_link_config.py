#!/usr/bin/env python3
import os
import re
from pathlib import Path


PKG_FILES = [
    Path("IR/moon.pkg"),
    Path("unsafe/moon.pkg"),
    Path("test/moon.pkg"),
    Path("tutorial/moon.pkg"),
]


def quote(value: str) -> str:
    return value.replace("\\", "\\\\").replace('"', '\\"')


cc = os.environ.get("CC", "clang")
cc_flags = os.environ["CC_FLAGS"]
cc_link_flags = os.environ["CC_LINK_FLAGS"]

link_config = f'''  link: {{
    "native": {{
      "cc": "{quote(cc)}",
      "cc-flags": "{quote(cc_flags)}",
      "cc-link-flags": "{quote(cc_link_flags)}",
    }},
  }},'''

link_config_pattern = re.compile(
    r'''  link: \{
    "native": \{
      "cc": "[^"]*",
      "cc-flags": "[^"]*",
      "cc-link-flags": "[^"]*",
    \},
  \},?''',
    re.MULTILINE,
)

for pkg_file in PKG_FILES:
    content = pkg_file.read_text()
    updated, count = link_config_pattern.subn(link_config, content)
    if count != 1:
        raise RuntimeError(f"expected one native link block in {pkg_file}, found {count}")
    pkg_file.write_text(updated)
    print(f"updated {pkg_file}")

print(f"CC={cc}")
print(f"CC_FLAGS={cc_flags}")
print(f"CC_LINK_FLAGS={cc_link_flags}")
