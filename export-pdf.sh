#!/usr/bin/env bash

set -euo pipefail

root_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source_html="$root_dir/index.html"
output_pdf="$root_dir/dist/CV Gilles Lepretre.pdf"
title="CV Gilles Lepretre"
author="Gilles Lepretre"
subject="Développeur full-stack avec 13 ans d'expérience. Expert en web moderne (React, Vue, TypeScript, Node, Python)."
keywords="CV, Gilles Lepretre, Développeur full-stack, Lyon, React, Vue, Python, Node.js, HTML, CSS, JavaScript, TypeScript, Next.js, Django, Flask, PostgreSQL, Docker, IA, agents, agentique, LLM, OpenCode, OpenRouter, GPT, Codex, Claude, Gemini"

if [[ -n "${CHROME_BIN:-}" ]]; then
  chrome="$CHROME_BIN"
elif command -v google-chrome >/dev/null 2>&1; then
  chrome="$(command -v google-chrome)"
elif command -v chromium >/dev/null 2>&1; then
  chrome="$(command -v chromium)"
else
  printf 'Google Chrome or Chromium is required.\n' >&2
  exit 1
fi

if ! command -v exiftool >/dev/null 2>&1; then
  printf 'ExifTool is required to preserve PDF metadata.\n' >&2
  exit 1
fi

temporary_dir="$(mktemp -d)"
temporary_pdf="$temporary_dir/resume.pdf"
trap 'rm -rf -- "$temporary_dir"' EXIT

"$chrome" \
  --headless \
  --no-pdf-header-footer \
  --virtual-time-budget=3000 \
  --print-to-pdf="$temporary_pdf" \
  "file://$source_html"

exiftool \
  -overwrite_original \
  "-PDF:Title=$title" \
  "-PDF:Author=$author" \
  "-PDF:Creator=$author" \
  "-PDF:Subject=$subject" \
  "-PDF:Keywords=$keywords" \
  "-XMP-dc:Title=$title" \
  "-XMP-dc:Creator=$author" \
  "-XMP-dc:Subject=$subject" \
  "-XMP-pdf:Author=$author" \
  "-XMP-pdf:Keywords=$keywords" \
  "$temporary_pdf"

if [[ -f "$output_pdf" ]]; then
  chmod --reference="$output_pdf" "$temporary_pdf"
fi
mv -- "$temporary_pdf" "$output_pdf"

printf 'PDF exported to %s\n' "$output_pdf"
