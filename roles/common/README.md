Role Name
=========

This is a role shared by all hosts in the inventory. In this case it installs basic PLC software such as TwinCAT and the OPC-UA server function and performs common setup tasks.

Requirements
------------

The IPC should have winrm enabled as described in the main README.

Role Variables
--------------

Currently only one variable is defined for this role, under roles/common/vars/main.yml. Is is the `tf6100_max_structure_size` variable which will be used to set the maximum structure size for the OPC-UA server. This is useful if you need to increase the maximum structure size to support larger structures.

Dependencies
------------

A list of other roles hosted on Galaxy should go here, plus any details in regards to parameters that may need to be set for other roles, or variables that are used from other roles.
