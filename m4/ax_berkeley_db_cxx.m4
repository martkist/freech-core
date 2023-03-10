# ===========================================================================
#    http://www.gnu.org/software/autoconf-archive/ax_berkeley_db_cxx.html
# ===========================================================================
#
# SYNOPSIS
#
#   AX_BERKELEY_DB_CXX([MINIMUM-VERSION [, ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND]]])
#
# DESCRIPTION
#
#   This macro tries to find Berkeley DB C++ support. It honors
#   MINIMUM-VERSION if given.
#
#   If libdb_cxx is found, DB_CXX_HEADER and DB_CXX_LIBS variables are set
#   and ACTION-IF-FOUND shell code is executed if specified. DB_CXX_HEADER
#   is set to location of db.h header in quotes (e.g. "db3/db_cxx.h") and
#   AC_DEFINE_UNQUOTED is called on it, so that you can type
#
#     #include DB_CXX_HEADER
#
#   in your C/C++ code. DB_CXX_LIBS is set to linker flags needed to link
#   against the library (e.g. -ldb3.1_cxx) and AC_SUBST is called on it.
#
#   when specified user-selected spot (via --with-libdb) also sets
#
#     DB_CXX_CPPFLAGS to the include directives required
#     DB_CXX_LDFLAGS to the -L flags required
#
# LICENSE
#
#   Copyright (c) 2008 Vaclav Slavik <vaclav.slavik@matfyz.cz>
#   Copyright (c) 2011 Stephan Suerken <absurd@debian.org>
#   Copyright (c) 2014 Kirill A. Korinskiy <catap@catap.ru>
#
#   Copying and distribution of this file, with or without modification, are
#   permitted in any medium without royalty provided the copyright notice
#   and this notice are preserved. This file is offered as-is, without any
#   warranty.

#serial 4

AC_DEFUN([AX_BERKELEY_DB_CXX],
[
  AC_LANG_ASSERT(C++)

  old_LIBS="$LIBS"
  old_LDFLAGS="$LDFLAGS"
  old_CPPFLAGS="$CPPFLAGS"

  libdbdir=""
  AC_ARG_WITH(libdb,
    AS_HELP_STRING([--with-libdb=DIR],
        [root of the Berkeley DB directory]),
    [
        case "$withval" in
        "" | y | ye | yes | n | no)
        AC_MSG_ERROR([Invalid --with-libdb value])
          ;;
        *) libdbdir="$withval"
          ;;
        esac
    ], [])

  minversion=ifelse([$1], ,,$1)

  DB_CXX_HEADER=""
  DB_CXX_LIBS=""
  DB_CXX_LDFLAGS=""
  DB_CXX_CPPFLAGS=""

  if test -z $minversion ; then
      minvermajor=0
      minverminor=0
      minverpatch=0
      AC_MSG_CHECKING([for Berkeley DB (C++)])
  else
      minvermajor=`echo $minversion | cut -d. -f1`
      minverminor=`echo $minversion | cut -d. -f2`
      minverpatch=`echo $minversion | cut -d. -f3`
      minvermajor=${minvermajor:-0}
      minverminor=${minverminor:-0}
      minverpatch=${minverpatch:-0}
      AC_MSG_CHECKING([for Berkeley DB (C++) >= $minversion])
  fi

  if test x$libdbdir != x""; then
    DB_CXX_CPPFLAGS="-I${libdbdir}/include"
    DB_CXX_LDFLAGS="-L${libdbdir}/lib"
    LDFLAGS="$DB_CXX_LDFLAGS $old_LDFLAGS"
    CPPFLAGS="$DB_CXX_CPPFLAGS $old_CPPFLAGS"
  fi

  for version in "" 5.0 4.9 4.8 4.7 4.6 4.5 4.4 4.3 4.2 4.1 4.0 3.6 3.5 3.4 3.3 3.2 3.1 ; do

    if test -z $version ; then
        db_cxx_lib="-ldb_cxx -ldb"
        try_headers="db_cxx.h"
    else
        db_cxx_lib="$libdbdir -ldb_cxx-$version -ldb-$version"
        try_headers="db$version/db_cxx.h db`echo $version | sed -e 's,\..*,,g'`/db_cxx.h db_cxx.h"
    fi

    LIBS="$db_cxx_lib $old_LIBS"

    for db_cxx_hdr in $try_headers ; do
        if test -z $DB_CXX_HEADER ; then
            AC_LINK_IFELSE(
                [AC_LANG_PROGRAM(
                    [
                        #include <${db_cxx_hdr}>
                    ],
                    [
                        #if !((DB_VERSION_MAJOR > (${minvermajor}) || \
                              (DB_VERSION_MAJOR == (${minvermajor}) && \
                                    DB_VERSION_MINOR > (${minverminor})) || \
                              (DB_VERSION_MAJOR == (${minvermajor}) && \
                                    DB_VERSION_MINOR == (${minverminor}) && \
                                    DB_VERSION_PATCH >= (${minverpatch}))))
                            #error "too old version"
                        #endif

                        DB *db;
                        db_create(&db, NULL, 0);
                    ])],
                [
                    AC_MSG_RESULT([header $db_cxx_hdr, library $db_cxx_lib])

                    DB_CXX_HEADER="$db_cxx_hdr"
                    DB_CXX_LIBS="$db_cxx_lib"
                ])
        fi
    done
  done

  LIBS="$old_LIBS"
  LDFLAGS="$old_LDFLAGS"
  CPPFLAGS="$old_CPPFLAGS"

  if test -z $DB_CXX_HEADER ; then
    AC_MSG_RESULT([not found])
    DB_CXX_LDFLAGS=""
    DB_CXX_CPPFLAGS=""
    ifelse([$3], , :, [$3])
  else
    AC_DEFINE_UNQUOTED(DB_CXX_HEADER, ["$DB_CXX_HEADER"], ["Berkeley DB C++ Header File"])
    AC_SUBST(DB_CXX_LIBS)
    AC_SUBST(DB_CXX_LDFLAGS)
    AC_SUBST(DB_CXX_CPPFLAGS)
    ifelse([$2], , :, [$2])
  fi
])
