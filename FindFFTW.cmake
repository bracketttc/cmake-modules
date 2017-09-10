#
# FindFFTW.cmake
#
# If found, create a CMake interface library fftw for ease of use. At this
# time, it is not deemed necessary to include the threading FFTW libraries.
#

find_path( FFTW_INCLUDE_DIR
    NAMES
    fftw3.h
    )

# double-precision library
find_library( FFTW_LIBRARY
    NAMES
    fftw3
    PATHS
    /usr/lib
    /usr/local/lib
    )

set( FFTW_LIBRARIES ${FFTW_LIBRARY} )

# alternate-precision libraries
# f = float
# l = long
# q = quad
set( LIBRARY_NAMES fftw3f fftw3l fftw3q )
foreach( FFTW_LIB_NAME ${LIBRARY_NAMES} )
    find_library( FFTW_${FFTW_LIB_NAME}_LIBRARY
        NAMES
        ${FFTW_LIB_NAME}
        PATHS
        /usr/lib
        /usr/local/lib
        )
    if( FFTW_${FFTW_LIB_NAME}_LIBRARY )
        list( APPEND FFTW_LIBRARIES ${FFTW_${FFTW_LIB_NAME}_LIBRARY} )
        mark_as_advanced( FFTW_${FFTW_LIB_NAME}_LIBRARY )
    endif()
endforeach()

include( FindPackageHandleStandardArgs )
find_package_handle_standard_args( FFTW "Could NOT find FFTW library (FFTW)" FFTW_LIBRARY FFTW_INCLUDE_DIR )

if( FFTW_INCLUDE_DIR AND FFTW_LIBRARY )
    if( NOT TARGET fftw )
        add_library( fftw INTERFACE )
        target_link_libraries( fftw
            INTERFACE
            ${FFTW_LIBRARIES}
            )
        target_include_directories( fftw
            INTERFACE
            ${FFTW_INCLUDE_DIR}
            )
    endif()

    mark_as_advanced( FFTW_INCLUDE_DIR FFTW_LIBRARY FFTW_LIBRARIES )
endif()
