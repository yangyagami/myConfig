(defun qt/insert-cmake-template ()
  (interactive)
  (insert  "cmake_minimum_required(VERSION 3.16)\n\nproject(helloworld VERSION 1.0.0 LANGUAGES CXX)\n\nset(CMAKE_CXX_STANDARD 17)\nset(CMAKE_CXX_STANDARD_REQUIRED ON)\n\nfind_package(Qt6 REQUIRED COMPONENTS Core)\n\nqt_standard_project_setup()\n\nqt_add_executable(helloworld\n     main.cpp\n )\n\ntarget_link_libraries(helloworld PRIVATE Qt6::Core)\n"))

(provide `init-qt)
