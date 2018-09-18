cmake_minimum_required(VERSION 2.8.3)
project(demo.oro)
set(EXE_NAME demo.elf)

# rules for dynamic components

find_package(OROCOS-RTT REQUIRED)
include(${OROCOS_INSTALL_DIR}/lib/cmake/orocos-rtt/UseOROCOS-RTT.cmake)
orocos_component(democomponents src/components.cpp)

# rules for static executable

add_executable(${EXE_NAME} src/main.cpp src/components.cpp)

target_compile_options(${EXE_NAME} PRIVATE)

target_link_libraries(${EXE_NAME}
	-static
	-L${OROCOS_INSTALL_DIR}/lib
	-lorocos-rtt-${OROCOS_TARGET}
	${EXTERNAL_LD_FLAGS}
)
