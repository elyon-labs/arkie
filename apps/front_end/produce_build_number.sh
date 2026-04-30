#!/bin/bash

file_contents=$(<BUILD_NUMBER)
result=$((file_contents + 1))
echo $result
