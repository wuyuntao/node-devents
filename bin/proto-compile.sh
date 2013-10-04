#!/bin/bash

for proto in $(find messages -name "*.proto"); do
    protoc --descriptor_set_out=$(echo $proto | sed -e 's/\.proto$/.desc/') --include_imports $proto
done
