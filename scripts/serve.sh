#!/bin/bash
rojo sourcemap --watch test.project.json --output sourcemap.json --include-non-scripts &
rojo serve
