#!/bin/bash

exit_status=0
for f in Testcase*/; do
    cur_status=0
    if [[ $f == "Testcase"*"Diff/" ]]; then
        continue
    fi
    
    cd $f
    first_v=""
    diffs_found=0
    for v in Version*.txt; do
        if [[ $v == *".1.txt" ]]; then
            first_v=$v
        else
            cmp -s $first_v $v
            if [ $? -ne 0 ]; then
                diffs_found=1
                diff -u $first_v $v > ../test.txt
                cd ..
                if [ -d ${f%/}"Diff/" ]; then
                    cd ${f%/}"Diff/"
                    if  [ -f ${v%.2.txt}"Diff.txt" ]; then
                        tail -n +3 ${v%.2.txt}"Diff.txt" > cmp1.txt
                        tail -n +3 "../test.txt" > cmp2.txt
                        cmp -s cmp1.txt cmp2.txt
                        if [ $? -ne 0 ]; then
                            cur_status=1
                        fi
                        rm -f cmp1.txt cmp2.txt
                    else
                        cur_status=1
                    fi
                    cd ..
                else
                    cur_status=1
                fi
                cd $f
            else 
                cd ..
                if [ -f "${f%/}Diff/${v%.2.txt}Diff.txt" ]; then
                    cur_status=1;
                fi
                cd $f
            fi
        fi
        
        if [ $cur_status -eq 1 ]; then
            exit_status=1
            break
        fi
    done

    cd ..
    if [ $diffs_found -eq 0 ]; then
        if [ -d "${f%/}Diff/" ]; then
            cur_status=1
            exit_status=1
        fi
    fi

    if [ $cur_status -eq 0 ]; then
        echo ${f%/}: PASS
    else
        echo ${f%/}: FAIL
    fi
done

rm -f test.txt
exit $exit_status