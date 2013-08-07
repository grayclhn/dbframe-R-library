## Copyright (C) 2011-2013 Gray Calhoun
##
## This program is free software: you can redistribute it and/or
## modify it under the terms of the GNU General Public License as
## published by the Free Software Foundation, either version 3 of the
## License, or (at your option) any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see
## <http://www.gnu.org/licenses/>.

    dbframe <- function(table, dbname = NULL, dbdriver = "SQLite",
                        data = NULL, readonly = FALSE, clear = FALSE,...) {
      x <- switch(dbdriver, 
                  "SQLite" = {
                    if (is.null(dbname)) {
                      warning("'dbname' is null; setting to ':memory:'")
                      dbname <- ":memory:"
                    }
                    if (dbname %in% c(":memory:", "")) {
                      dbframe_sqlite_temporary(table, dbname, readonly,...)
                    } else {
                      dbframe_sqlite(table, dbname, readonly,...)
                    }
                  },
                  dbframe_unknown(table, readonly,...))
          if (clear) clear.result <- clear(x)
          if (!is.null(data)) insert(x) <- data
      return(x)
    }

        dbframe_sqlite <- function(table, dbname, readonly = FALSE,...) {
              require(RSQLite)
              require(RSQLite.extfuns)
          return(new("dbframe_sqlite", table = unname(table), rowid = integer(),
                     dbname = unname(dbname), readonly = unname(readonly),
                     dbConnect.arguments = list(...)))
        }
        dbframe_sqlite_temporary <- 
          function(table, dbname = ":memory:", readonly = FALSE,...)
          stop("Temporary SQLite databases aren't implemented.")
        dbframe_unknown <- function(table, readonly = FALSE,...) {
          return(new("dbframe", table = unname(table), 
                     readonly = unname(readonly),
                     dbConnect.arguments = list(...)))
        }