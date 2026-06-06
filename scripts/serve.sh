#!/bin/bash
rojo sourcemap --watch default.project.json --output sourcemap.json --include-non-scripts &
rojo serve default.project.json
