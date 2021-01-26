set(POLICY_NAME "dataworld")

string(REPLACE "_" "-" POLICY_NAME_HYPHENS ${POLICY_NAME})
set(IRODS_PACKAGE_COMPONENT_POLICY_NAME ${POLICY_NAME_HYPHENS})
set(TOUPPER IRODS_PACKAGE_COMPONENT_POLICY_NAME_UPPERCASE ${IRODS_PACKAGE_COMPONENT_POLICY_NAME})

set(TARGET_NAME "${IRODS_TARGET_NAME_PREFIX}-${POLICY_NAME}")

macro(IRODS_MACRO_CHECK_DEPENDENCY_SET_FULLPATH_ADD_TO_IRODS_COMPONENT_PACKAGE_DEPENDENCIES_LIST COMPONENT_NAME DEPENDENCY_NAME DEPENDENCY_SUBDIRECTORY)
  IRODS_MACRO_CHECK_DEPENDENCY_SET_FULLPATH(${DEPENDENCY_NAME} ${DEPENDENCY_SUBDIRECTORY})
  list(APPEND IRODS_${COMPONENT_NAME}_PACKAGE_DEPENDENCIES_LIST irods-externals-${DEPENDENCY_SUBDIRECTORY})
endmacro()

IRODS_MACRO_CHECK_DEPENDENCY_SET_FULLPATH_ADD_TO_IRODS_COMPONENT_PACKAGE_DEPENDENCIES_LIST("${IRODS_PACKAGE_COMPONENT_POLICY_NAME_UPPERCASE}" ELASTIC_CLIENT elasticlient0.1.0-1)
IRODS_MACRO_CHECK_DEPENDENCY_SET_FULLPATH_ADD_TO_IRODS_COMPONENT_PACKAGE_DEPENDENCIES_LIST("${IRODS_PACKAGE_COMPONENT_POLICY_NAME_UPPERCASE}" CPR cpr1.3.0-1)
string(REPLACE ";" ", " IRODS_${IRODS_PACKAGE_COMPONENT_POLICY_NAME_UPPERCASE}_PACKAGE_DEPENDENCIES_STRING "${IRODS_${IRODS_PACKAGE_COMPONENT_POLICY_NAME_UPPERCASE}_PACKAGE_DEPENDENCIES_LIST}")

set(
  IRODS_PLUGIN_POLICY_COMPILE_DEFINITIONS
  IRODS_QUERY_ENABLE_SERVER_SIDE_API
  ENABLE_RE
  )

set(
  IRODS_PLUGIN_POLICY_LINK_LIBRARIES
  irods_server
  )

add_library(
    ${TARGET_NAME}
    MODULE
    ${CMAKE_SOURCE_DIR}/lib${TARGET_NAME}.cpp
    ${CMAKE_SOURCE_DIR}/utilities.cpp
    ${CMAKE_SOURCE_DIR}/configuration.cpp
    ${CMAKE_SOURCE_DIR}/plugin_specific_configuration.cpp
    )

target_include_directories(
    ${TARGET_NAME}
    PRIVATE
    ${IRODS_INCLUDE_DIRS}
    ${IRODS_EXTERNALS_FULLPATH_BOOST}/include
    ${IRODS_EXTERNALS_FULLPATH_JSON}/include
    ${IRODS_EXTERNALS_FULLPATH_JANSSON}/include
    ${CMAKE_CURRENT_SOURCE_DIR}/include
    ${IRODS_EXTERNALS_FULLPATH_ELASTIC_CLIENT}/include/
    ${IRODS_EXTERNALS_FULLPATH_CPR}/include/
    )

target_link_libraries(
    ${TARGET_NAME}
    PRIVATE
    ${IRODS_PLUGIN_POLICY_LINK_LIBRARIES}
    ${IRODS_EXTERNALS_FULLPATH_BOOST}/lib/libboost_filesystem.so
    ${IRODS_EXTERNALS_FULLPATH_BOOST}/lib/libboost_system.so
    ${IRODS_EXTERNALS_FULLPATH_ELASTIC_CLIENT}/lib/libelasticlient.so
    ${IRODS_EXTERNALS_FULLPATH_ELASTIC_CLIENT}/lib/libjsoncpp.so
    ${IRODS_EXTERNALS_FULLPATH_CPR}/lib/libcpr.so
    irods_common
    )

target_compile_definitions(${TARGET_NAME} PRIVATE ${IRODS_PLUGIN_POLICY_COMPILE_DEFINITIONS} ${IRODS_COMPILE_DEFINITIONS} BOOST_SYSTEM_NO_DEPRECATED)
target_compile_options(${TARGET_NAME} PRIVATE -Wno-write-strings)
set_property(TARGET ${TARGET_NAME} PROPERTY CXX_STANDARD ${IRODS_CXX_STANDARD})

install(
  TARGETS
  ${TARGET_NAME}
  LIBRARY
  DESTINATION ${IRODS_PLUGINS_DIRECTORY}/rule_engines
  COMPONENT ${IRODS_PACKAGE_COMPONENT_POLICY_NAME}
  )

set(CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA "${CMAKE_SOURCE_DIR}/packaging/postinst_movement;")
set(CPACK_RPM_POST_INSTALL_SCRIPT_FILE "${CMAKE_SOURCE_DIR}/packaging/postinst_movement")

set(CPACK_DEBIAN_${IRODS_PACKAGE_COMPONENT_POLICY_NAME_UPPERCASE}_PACKAGE_NAME ${TARGET_NAME})
set(CPACK_DEBIAN_${IRODS_PACKAGE_COMPONENT_POLICY_NAME_UPPERCASE}_PACKAGE_DEPENDS "${IRODS_PACKAGE_DEPENDENCIES_STRING}, ${IRODS_${IRODS_PACKAGE_COMPONENT_POLICY_NAME_UPPERCASE}_PACKAGE_DEPENDENCIES_STRING}, irods-server (= ${IRODS_VERSION}), irods-runtime (= ${IRODS_VERSION}), libc6")

set(CPACK_RPM_${IRODS_PACKAGE_COMPONENT_POLICY_NAME}_PACKAGE_NAME ${TARGET_NAME})
if (IRODS_LINUX_DISTRIBUTION_NAME STREQUAL "centos" OR IRODS_LINUX_DISTRIBUTION_NAME STREQUAL "centos linux")
    set(CPACK_RPM_${IRODS_PACKAGE_COMPONENT_POLICY_NAME}_PACKAGE_REQUIRES "${IRODS_PACKAGE_DEPENDENCIES_STRING}, ${IRODS_${IRODS_PACKAGE_COMPONENT_POLICY_NAME_UPPERCASE}_PACKAGE_DEPENDENCIES_STRING}, irods-server = ${IRODS_VERSION}, irods-runtime = ${IRODS_VERSION}")
elseif (IRODS_LINUX_DISTRIBUTION_NAME STREQUAL "opensuse")
    set(CPACK_RPM_${IRODS_PACKAGE_COMPONENT_POLICY_NAME}_PACKAGE_REQUIRES "${IRODS_PACKAGE_DEPENDENCIES_STRING}, ${IRODS_${IRODS_PACKAGE_COMPONENT_POLICY_NAME_UPPERCASE}_PACKAGE_DEPENDENCIES_STRING}, irods-server = ${IRODS_VERSION}, irods-runtime = ${IRODS_VERSION}")
endif()

