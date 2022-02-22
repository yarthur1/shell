#!/bin/bash

function gendir() {
    src_dir=$1  # 传入的路径后面需要有/  /data/proto/
    dst_dir=$2
    res=`find $src_dir -name "*.proto"`

    for src_file in $res
    do
    echo "$src_file"
    file=(`echo $src_file | sed "s#$src_dir##"`)  # 删除原路径
    echo $file
    filename=`echo $file|awk -F'/' '{print $NF}'` # 获取文件名
    echo $filename
    path=(`echo $file|sed "s#$filename##"`)  # 删除文件名，获取需要在dst_dir创建的目录
    echo $dst_dir$path
    mkdir -p $dst_dir$path
    echo $dst_dir$file
    cp $src_file $dst_dir$file
    done;
}

gendir $1 $2  # 传入的路径后面需要有/  /data/src/  /data/dst/