#
# AppHarden.cmake
#
# This cmake module provides configuration-time options to enable various
# application hardening compilation options for all build targets. This module
# also provides interface libraries for the various features that can be used
# as target dependencies that require application hardening without applying
# those options to all targets in a project.
#

cmake_minimum_required( VERSION 3.0.2 )

option( APPHARDEN_ALL   "Apply all application hardening options. (May impact \
performance)" OFF )
option( APPHARDEN_STACK "Add stack-protection code: stack canaries and \
range-checking (May impact performance)" OFF )
option( APPHARDEN_GOT   "(ELF only) Mark global offset table read only \
and force immediate binding." OFF )
option( APPHARDEN_ASLR  "Enable options related to address space layout \
randomization." OFF )

#
# Add stack-protection code: stack canaries and range-checking (May impact
# performance)
#
# Options applied vary by compiler vendor and version. Some compiler versions
# do not support recommended options and will issue CMake configuration
# warnings.
#
add_library( ah_stack )
if( MSVC )
    #
    # Microsoft Visual C++ compiler from 2003 on supports an option that it
    # calls Buffer Security Check (/GS), from 2005 on this option is enabled by
    # default.
    #
    if( CMAKE_C_COMPILER_VERSION VERSION_LESS 13 )
        message( WARNING "Microsoft Visual Studio prior to .NET 2003 does not \
support the Buffer Security Check (/GS) option. Upgrade to a newer version of \
Microsoft Visual Studio to enable" )
    else()
        set_target_properties( ah_stack PROPERTIES
                               INTERFACE_COMPILE_OPTIONS
                               "/GS" )
    endif()
elseif( CMAKE_C_COMPILER_ID STREQUAL "GNU" )
    #
    # GNU CC supports a system of stack canaries.
    #
    if( CMAKE_C_COMPILER_VERSION VERSION_LESS 4.1 )
        message( WARNING "GNU CC ${CMAKE_C_COMPILER_VERSION} does not support \
stack protection code generation. Upgrade to GNU CC 4.1 or later (recommend 4.8 \
or later)." )
    elseif( CMAKE_C_COMPILER_VERSION VERSION_LESS 4.8 )
        message( WARNING "GNU CC ${CMAKE_C_COMPILER_VERSION} does not support \
improved stack protection heuristics. Upgrade to GNU CC 4.8 or later." )
        set_target_properties( ah_stack PROPERTIES
                               INTERFACE_COMPILE_OPTIONS
                               "-fstack-protector-all" )
    else()
        set_target_properties( ah_stack PROPERTIES
                               INTERFACE_COMPILE_OPTIONS
                               "-fstack-protector-strong" )
    endif()
elseif( CMAKE_C_COMPILER_ID STREQUAL "Clang" OR
        CMAKE_C_COMPILER_ID STREQUAL "AppleClang" )
    #
    # LLVM Clang supports the -fstack-protector-strong option from GNU CC as
    # well as their own options.
    #
    message( WARNING "Clang support not yet implemented" )
endif()

#
# (ELF only) Mark global offset table read only and force immediate binding.
#
# Mitigates some memory corruption attacks. There is no analogous attack for
# Windows binaries.
#
add_library( ah_got INTERFACE )
if( UNIX )
    set_target_properties( ah_got PROPERTIES
                           INTERFACE_COMPILE_OPTIONS
                           "-Wl,-z,relro,-z,now" )
endif()


add_library( ah_aslr INTERFACE )
set_target_properties( ah_aslr PROPERTIES INTERFACE_POSITION_INDEPENDENT_CODE ON )


add_library( ah_all INTERFACE )
target_link_libraries( ah_all INTERFACE ah_stack ah_got ah_aslr )


if( APPHARDEN_ALL )
    option( APPHARDEN_STACK "Implied by APPHARDEN_ALL" CACHE ON )
    option( APPHARDEN_GOT   "Implied by APPHADREN_ALL" CACHE ON )
    option( APPHARDEN_ASLR  "Implied by APPHARDEN_ALL" CACHE ON )
endif()

if( APPHARDEN_STACK )
    link_libraries( ah_stack )
endif()

if( APPHARDEN_GOT )
    link_libraries( ah_got )
endif()

if( APPHARDEN_ASLR )
    link_libraries( ah_aslr )
endif()
