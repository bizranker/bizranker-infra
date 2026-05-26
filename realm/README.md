# BizRanker Realm

This folder is the operational catalogue for the BizRanker / US Reliance infrastructure realm.

## Purpose

This is not monitoring.

This is catalogue intelligence: a record of what each server is, why it exists, what services it runs, what apps it owns, and how it should eventually be recreated through Terraform and Ansible.

## Current Realm Classes

- core_demo_node
- ui_node
- postgres_node
- scraper_worker_node

## Current Hosts

- usreliance
- bizranker-web-01
- bizranker-db-01
- bizranker-worker-01

## Directory Layout

- inventory/ — Ansible-style host inventory
- classifications/ — server role definitions
- inspections/ — captured realm inspection outputs
- diagrams/ — future architecture diagrams

## Operating Principle

Discover reality first. Codify second. Automate third.
