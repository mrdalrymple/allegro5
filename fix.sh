#!/bin/sh
#
# Sets up the Allegro package for building with the specified compiler,
# and if possible converting text files to the desired target format.

proc_help()
{
   echo
   echo "Usage: ./fix.sh <platform> [--quick|--dtou|--utod|--utom|--mtou]"
   echo
   echo "Where platform is one of: bcc32, beos, djgpp, mingw32, msvc, qnx, rsxnt, unix"
   echo "mac and watcom."
   echo "The --quick parameter turns of text file conversion, --dtou converts from"
   echo "DOS/Win32 format to Unix, --utod converts from Unix to DOS/Win32 format,"
   echo "--utom converts from Unix to Macintosh format and --mtou converts from"
   echo "Macintosh to Unix format. If no parameter is specified --dtou is assumed."
   echo

   AL_NOCONV="1"
}

proc_fix()
{
   echo "Configuring Allegro for $1..."

   if [ "$2" != "none" ]; then
      echo "# generated by fix.sh" > makefile
      echo "MAKEFILE_INC = $2" >> makefile
      echo "include makefile.all" >> makefile
   fi

   echo "/* generated by fix.sh */" > include/allegro/alplatf.h
   echo "#define $3" >> include/allegro/alplatf.h
}

proc_filelist()
{
   AL_FILELIST_DOS_OK=`find . -type f "(" \
      -name "*.c" -o -name "*.cfg" -o -name "*.cpp" -o -name "*.def" -o \
      -name "*.h" -o -name "*.hin" -o -name "*.in" -o -name "*.inc" -o \
      -name "*.m4" -o -name "*.mft" -o -name "*.s" -o \
      -name "*.spec" -o -name "*.pl" -o -name "*.txt" -o -name "*._tx" -o \
      -name "makefile*" -o -name "readme.*" -o \
      -name "CHANGES" -o -name "AUTHORS" -o -name "THANKS" \
   ")"`

   AL_FILELIST="$AL_FILELIST_DOS_OK `find . -type f -name '*.sh'`"
}

proc_utod()
{
   echo "Converting files from Unix to DOS/Win32..."
   proc_filelist
   for file in $AL_FILELIST_DOS_OK; do
      echo "$file"
      cp $file _tmpfile
      perl -p -i -e "s/([^\r]|^)\n/\1\r\n/" _tmpfile
      touch -r $file _tmpfile
      mv _tmpfile $file
   done
}

proc_dtou()
{
   echo "Converting files from DOS/Win32 to Unix..."
   proc_filelist
   for file in $AL_FILELIST; do
      echo "$file"
      mv $file _tmpfile
      tr -d '\015' < _tmpfile > $file
      touch -r _tmpfile $file
      rm _tmpfile
   done
   chmod +x configure *.sh misc/*.sh misc/*.pl
}

proc_utom()
{
   echo "Converting files from Unix to Macintosh..."
   proc_filelist
   for file in $AL_FILELIST; do
      echo "$file"
      mv $file _tmpfile
      tr '\012' '\015' < _tmpfile > $file
      touch -r _tmpfile $file
      rm _tmpfile
   done
}

proc_mtou()
{
   echo "Converting files from Macintosh to Unix..."
   proc_filelist
   for file in $AL_FILELIST; do
      echo "$file"
      mv $file _tmpfile
      tr '\015' '\012' < _tmpfile > $file
      touch -r _tmpfile $file
      rm _tmpfile
   done
}

# take action!

case "$1" in
   "bcc32"   ) proc_fix "Windows (BCC32)"   "makefile.bcc" "ALLEGRO_BCC32";;
   "beos"    ) proc_fix "BeOS"              "makefile.be"  "ALLEGRO_BEOS";;
   "djgpp"   ) proc_fix "DOS (djgpp)"       "makefile.dj"  "ALLEGRO_DJGPP";;
   "mingw32" ) proc_fix "Windows (Mingw32)" "makefile.mgw" "ALLEGRO_MINGW32";;
   "msvc"    ) proc_fix "Windows (MSVC)"    "makefile.vc"  "ALLEGRO_MSVC";;
   "qnx"     ) proc_fix "QNX"               "makefile.qnx" "ALLEGRO_QNX";;
   "rsxnt"   ) proc_fix "Windows (RSXNT)"   "makefile.rsx" "ALLEGRO_RSXNT";;
   "unix"    ) proc_fix "Unix"              "none"         "ALLEGRO_UNIX";;
   "mac"     ) proc_fix "Mac"               "none"         "ALLEGRO_MPW";;
   "watcom"  ) proc_fix "DOS (Watcom)"      "makefile.wat" "ALLEGRO_WATCOM";;
   "help"    ) proc_help;;
   *         ) proc_help;;
esac

# someone ordered a text conversion?

case "$2" in
   "--utod"  ) proc_utod;;
   "--dtou"  ) proc_dtou;;
   "--utom"  ) proc_utom;;
   "--mtou"  ) proc_mtou;;
   "--quick" ) echo "No text file conversion...";;
   *         ) if [ "$AL_NOCONV" != "1" ]; then
                  proc_dtou
               fi;;
esac

echo "Done!"
