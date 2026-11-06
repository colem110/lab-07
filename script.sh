#!/bin/bash

# Removes any Testcase#Diff directories
for v in Testcase*Diff/; do
    rm -rf $v
done

# Loops through Testcase# directories
for f in Testcase*/; do
    first_txt=""
    cd $f

    # Compares .txts in Testcase# directory
    # If different, output diff output to Testcase#Diff directory
    for text in Version*.txt; do
        if [[ $text == *".1.txt" ]]; then
            first_txt=$text
        else
            diff -u $first_txt $text
            if [ $? -ne 0 ]; then
                # Creates directory and places diff output inside
                diff -u $first_txt $text > "${text%.2.txt}Diff.txt"
                mv "${text%.2.txt}Diff.txt" ..
                cd ..
                mkdir "${f%/}Diff/"
                mv "${text%.2.txt}Diff.txt" "${f%/}Diff/"
                cd $f
            fi
        fi
    done
    # Changes back to root folder
    cd ..
done