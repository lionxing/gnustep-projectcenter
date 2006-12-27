#
# GNUmakefile - Generated by ProjectCenter
#

GNUSTEP_INSTALLATION_DOMAIN = SYSTEM
include $(GNUSTEP_MAKEFILES)/common.make

#
# Framework
#
VERSION = 0.5.0
FRAMEWORK_NAME = ProjectCenter
ProjectCenter_CURRENT_VERSION_NAME = 0.5.0
ProjectCenter_DEPLOY_WITH_CURRENT_VERSION = yes
ProjectCenter_HEADER_FILES_DIR = ../Headers/ProjectCenter

ProjectCenter_LIBRARIES_DEPEND_UPON += -lgnustep-gui

#
# Subprojects
#
#SUBPROJECTS = Resources

#
# Header files
#
ProjectCenter_HEADER_FILES = \
  PCDefines.h \
  ProjectCenter.h \
  \
  PCBundleManager.h \
  PCFileManager.h \
  PCAddFilesPanel.h \
  PCFileCreator.h \
  PCMakefileFactory.h \
  \
  PCProjectManager.h \
  PCProject.h \
  PCProjectWindow.h \
  PCProjectInspector.h \
  PCProjectBuilder.h \
  PCProjectBuilderPanel.h \
  PCProjectLauncher.h \
  PCProjectLauncherPanel.h \
  PCProjectEditor.h \
  \
  PCProjectBrowser.h \
  PCProjectLoadedFiles.h \
  PCProjectLoadedFilesPanel.h \
  \
  PCPrefController.h \
  PCLogController.h

#
# Class files
#

ProjectCenter_OBJC_FILES = \
  PCBundleManager.m \
  PCMakefileFactory.m \
  PCFileManager.m \
  PCAddFilesPanel.m \
  PCFileCreator.m \
  \
  PCProjectManager.m \
  PCProject.m \
  PCProjectWindow.m \
  PCProjectInspector.m \
  PCProjectBuilder.m \
  PCProjectBuilderPanel.m \
  PCProjectLauncher.m \
  PCProjectLauncherPanel.m \
  PCProjectEditor.m \
  \
  PCProjectBrowser.m \
  PCProjectLoadedFiles.m \
  PCProjectLoadedFilesPanel.m \
  \
  PCSplitView.m \
  PCButton.m \
  PCFileNameField.m \
  PCFileNameIcon.m \
  \
  PCPrefController.m \
  PCLogController.m

#
# Resources
#
ProjectCenter_RESOURCE_FILES = \
  Resources/cfile.template \
  Resources/cheader.template \
  Resources/class.template \
  Resources/gsmarkup.template \
  Resources/header.template \
  Resources/postamble.template \
  Resources/protocol.template \

#
# Localization
#
ProjectCenter_LOCALIZED_RESOURCE_FILES = \
  ProjectWindow.gorm \
  NewSubproject.gorm \
  NewFile.gorm \
  ProjectInspector.gorm \
  BuildAttributes.gorm \
  ProjectAttributes.gorm \
  ProjectDescription.gorm \
  FileAttributes.gorm \
  LogPanel.gorm \
  Preferences.gorm

ProjectCenter_LANGUAGES = \
English


-include GNUmakefile.preamble

include $(GNUSTEP_MAKEFILES)/framework.make
include $(GNUSTEP_MAKEFILES)/aggregate.make

-include GNUmakefile.postamble