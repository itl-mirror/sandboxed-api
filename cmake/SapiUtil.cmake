# Copyright 2019 Google LLC. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Creates an alias for SOURCE, called DESTINATION.
#
# On platforms that support them, this rule will effectively create a symlink.
#
# SOURCE may be relative to CMAKE_CURRENT_SOURCE_DIR, or absolute.
# DESTINATION may relative to CMAKE_CURRENT_BINARY_DIR, or absolute.
#
# Adapted from https://github.com/google/binexport/blob/master/util.cmake
function(create_directory_symlink SOURCE DESTINATION)
  get_filename_component(_destination_parent "${DESTINATION}" DIRECTORY)
  file(MAKE_DIRECTORY "${_destination_parent}")

  if (WIN32)
    file(TO_NATIVE_PATH "${SOURCE}" _native_source)
    file(TO_NATIVE_PATH "${DESTINATION}" _native_destination)
    execute_process(COMMAND $ENV{ComSpec} /c
        mklink /J "${_native_destination}" "${_native_source}" ERROR_QUIET)
  else()
    execute_process(COMMAND ${CMAKE_COMMAND} -E
      create_symlink "${SOURCE}" "${DESTINATION}")
  endif()
endfunction()

# Helper function that behaves just like protobuf_generate_cpp(), except that
# it strips import paths. This is necessary, because CMake's protobuf rules
# don't work well with imports across different directories.
function(protobuf_generate_cpp SRCS HDRS PROTO)
  file(READ ${PROTO} _pb_orig)
  string(REGEX REPLACE "import \".*/([^/]+\\.proto)\""
                       "import \"\\1\"" _pb_repl "${_pb_orig}")
  file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/${PROTO} "${_pb_repl}")
  # Call original function
  _protobuf_generate_cpp(_srcs _hdrs ${CMAKE_CURRENT_BINARY_DIR}/${PROTO})
  set(${SRCS} ${_srcs} PARENT_SCOPE)
  set(${HDRS} ${_hdrs} PARENT_SCOPE)
endfunction()
