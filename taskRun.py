#*****************************************************************************
#    # #              Name   : taskRun.py
#  #     #            Date   : Mar. 24, 2020
# #    #  #  #     #  Author : Qiwei Wu
#  #     #  # #  # #  Version: 1.0
#    # #  #    #   #
# taskRun.py
#
# Change History:
#  VER.   Author         DATE              Change Description
#  1.0    Qiwei Wu       Mar. 24, 2021     Initial Release
#*****************************************************************************
#!/usr/bin/python

import os
import sys
import time
import shutil
from optparse import OptionParser

#*****************************************************************************
# Build setting
#*****************************************************************************
parser = OptionParser()
parser.add_option( "-p", "--project", dest="projectName", help="Build project's name" )
( options, args ) = parser.parse_args()

workPath = os.path.abspath( os.getcwd() ) + "/"
buildPath = workPath + ".build/"
resPath = workPath + ".task/"
taskPath = workPath + "task/"

#*****************************************************************************
# Make folder
#*****************************************************************************
def MkdirRes():
   if os.path.exists( resPath ):
      shutil.rmtree( resPath )
      print( "%s is removed" % ( resPath ) )
   os.makedirs( resPath )
   print( "%s is created" % ( resPath ), 'none' )
   print( "Starting......")

#*****************************************************************************
# Build Start
#*****************************************************************************
if __name__ == "__main__":
   MkdirRes()

   if options.projectName is None:
      print( "Missing project name, please type '%s -h' for more details" % ( __file__ ) )
      sys.exit( -1 )

   # build start
   if options.projectName == 'all':
      projectItems = os.listdir( taskPath )
      projectNum = len( projectItems )
   else:
      projectItems[0] = options.projectName
      projectNum = 1

   print( "%d projects need to be built" % ( projectNum ) )

   # build needed project
   for i in range( 0, projectNum ):
      print( "No.%d project %s is building now" % ( i, projectItems[i] ) )

      if not os.path.exists( taskPath + projectItems[i] + '/Makefile' ):
         print( "No build script found" )
         sys.exit( -1 )
      else:
         os.makedirs( resPath + projectItems[i] )
         os.chdir( taskPath + projectItems[i] )
         os.system( 'make sim' )
         os.system( 'make clean' )
         os.chdir( workPath )
         for path, dirs, files in os.walk( taskPath + projectItems[i], topdown = False ):
            for name in files:
               if not "Makefile" in name:
                  fileSrcPath = os.path.join( path, name )
                  fileDestPath = os.path.join( resPath + projectItems[i], name )
                  shutil.copy( fileSrcPath, fileDestPath )
                  print( "Copping %s into %s" % ( name, resPath + projectItems[i] ) )

   # finish
   print( "Finish building Project %s" % ( options.projectName ) )
