# Incomplete Design

## Overview

A fixture that intentionally omits the Sprint Contract section so team-plan can be tested for fail-fast behavior.

## Motivation

- Verify that team-plan stops without writing a plan when `## Sprint Contract` is absent.

## Design

### Goal

Ensure team-plan emits the documented guidance message and exits before writing any file.
