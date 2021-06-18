import os
import re


def get_text_list():
	rootdir = "C:/Users/Rede LEONA/Downloads/Jose Downloads/OpenCV/Reviewed nights/Anillaco"
	# Look for unedited video clips
	regextxt = re.compile("(.*txt$)")
	text_list = []
	for root, dirs, files in os.walk(rootdir):
		for file in files:
			path = os.path.join(root,file)
			string_match = regextxt.match(path)
			if string_match:
				text_list.append(path)
	return text_list

file_list = get_text_list()

regextxt = re.compile("(.*)((\\\)(.*)(.*.txt$))$")
for text_file in file_list:
	string_match = regextxt.match(text_file)
	print(string_match.group(4))
	# with open(text_file) as file:
	# 	print(file.read())

