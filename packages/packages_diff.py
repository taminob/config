#!/bin/python

import glob
import os
import socket
import subprocess
import sys

packages_path = "/home/me/sync/config/packages"

platform_packages = socket.gethostname() + "_packages_"
if len(sys.argv) > 1:
	platform_packages = sys.argv[1] + "_packages_"

packages_list = glob.glob(packages_path + "/*_packages")
packages_list.append(packages_path + "/aur_packages_")
packages_list.append(packages_path + "/" + platform_packages)

def get_pacman(args):
	installed_packages = []
	for line in subprocess.check_output(["pacman", args]).splitlines():
		installed_packages.append(str(line, 'UTF-8').split(' ', 1)[0])
	return installed_packages

all_packages = {}
for file_name in packages_list:
	file_packages = []
	with open(file_name, "r") as f:
		for line in f:
			comment_pos = line.find("#")
			line_end = len(line) if (comment_pos < 0) else comment_pos
			file_packages.extend(line[:line_end].split())
	all_packages[file_name] = file_packages

installed_packages = get_pacman("-Q")

for file_name, packages in all_packages.items():
	diff = [item for item in packages if item not in installed_packages]
	if len(diff) > 0:
		print("not installed " + os.path.basename(file_name) + ": ", diff)
	else:
		print("all " + file_name + " installed!")

if input("List all installed packages which are not in any list? (y/N)").upper() == "Y":
	installed_packages = get_pacman("-Qtt")
	all_packages = [item for p in all_packages.values() for item in p]
	manual_installed = []
	for x in installed_packages:
		if x not in all_packages:
			manual_installed.append(x)
	print(manual_installed)
