cmake_minimum_required(VERSION 3.28.1)
project(OSLAB)

function(set_target target)
    file(GLOB FILES "${target}/*.c")
    add_executable(${target} ${FILES})
    target_include_directories(${target} PRIVATE ${target})
endfunction()

set_target(debug)
