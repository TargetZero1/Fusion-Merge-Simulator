import os
import shutil
import io
import git
import shutil
import stat
import shutil
from subprocess import call

FUSION_BUILD_PATH = "./src/Fusion"

# Clone into temporary dir
FUSION_REPO_PATH = "./fusion"

git.Repo.clone_from('https://github.com/Elttob/Fusion.git', FUSION_REPO_PATH, branch='main', depth=1)

# # Copy desired file from temporary dir
if os.path.exists(FUSION_BUILD_PATH):
	shutil.rmtree(FUSION_BUILD_PATH)
shutil.move(FUSION_REPO_PATH+"/src", FUSION_BUILD_PATH)

# delete the directory
#from: https://stackoverflow.com/questions/4829043/how-to-remove-read-only-attrib-directory-with-python-in-windows
for FILE_NAME in os.listdir(FUSION_REPO_PATH):
	def on_rm_error(func, path, exc_info):	
		os.chmod(path, stat.S_IWRITE)
		os.unlink(path)

	if FILE_NAME.endswith('git'):
		FILE_PATH = os.path.join(FUSION_REPO_PATH, FILE_NAME)
		# We want to unhide the .git folder before unlinking it.
		while True:
			call(['attrib', '-H', FILE_PATH])
			break
		shutil.rmtree(FILE_PATH, onerror=on_rm_error)

shutil.rmtree(FUSION_REPO_PATH)

# make changes

def replaceString(path: str, old_string: str, new_string: str):
	# Safely read the input filename using 'with'
	with open(path) as f:
		s = f.read()
		if old_string not in s:
			return

	# Safely write the changed content, if found in the file
	with open(path, 'w') as f:
		print('Changing "{old_string}" to "{new_string}" in {path}'.format(**locals()))
		s = s.replace(old_string, new_string)
		f.write(s)

def updateLuaFile(FILE_PATH: str):
	replaceString(FILE_PATH, '--!strict', '--!nocheck')
	replaceString(FILE_PATH, '--!nonstrict', '--!nocheck')
	replaceString(FILE_PATH, 'for spring in pairs(activeSprings) do', 'for spring in pairs(activeSprings) do if not spring._currentSpeed then continue end;')
	replaceString(FILE_PATH, 'for tween: Tween in pairs(allTweens :: any) do', 'for tween: Tween in pairs(allTweens :: any) do if not tween._currentTweenStartTime then continue end;')
	replaceString(FILE_PATH, 'local goalValue = self._goalState:get(false)', 'local goalValue = if self._goalState then self._goalState:get(false) else nil; if goalValue == nil then return end;')
	replaceString(FILE_PATH, 
	"""
	"""
	)


def iterateThroughDirectory(DIR_PATH: str):
	for FILE_NAME in os.listdir(DIR_PATH):
		FILE_PATH = DIR_PATH+"/"+FILE_NAME
		if os.path.isdir(FILE_PATH):
			iterateThroughDirectory(FILE_PATH)
		elif FILE_NAME.endswith('lua'):
			updateLuaFile(FILE_PATH)

iterateThroughDirectory(FUSION_BUILD_PATH)