\documentclass[11pt,draft]{article}
\usepackage{amsmath,amsthm,amssymb,microtype,listings}
\usepackage[T1]{fontenc}
\usepackage[round]{natbib}
\usepackage[margin = 1in]{geometry}
\usepackage{fontspec}
\lstset{language=R,basicstyle=\ttfamily}
\DisableLigatures{family=tt*}
\frenchspacing
\raggedright

\title{Implementation details of the `dbframe'
  package\footnote{Copyright \textcopyright\ 2011 by Gray Calhoun}}
\date{\today}
\author{Gray Calhoun}

\bibliographystyle{abbrvnat}
\begin{document}

\maketitle
\tableofcontents

\section{The dbframe class}
@o R/AllClasses.R @{#
setClass("dbframe", representation(db = "character",
                                   sql = "character",
                                   extensions = "logical"))

setMethod("==", c("dbframe", "dbframe"), function(e1, e2)
          e1@@db == e2@@db & e1@@sql == e2@@sql & e1@@extensions == e2@@extensions)
setMethod("!=", c("dbframe", "dbframe"), function(e1, e2)
          e1@@db != e2@@db & e1@@sql != e2@@sql & e1@@extensions !=
          e2@@extensions)

setGeneric("sql", function(x) standardGeneric("sql"))

setMethod("sql", signature = c("dbframe"), function(x) x@@sql)
@| sql @}

And then we have the code to make a new dbframe
@o R/dbframe.R @{
dbframe <- function(table, dbname, data = NULL,
                    overwrite = FALSE, extensions = TRUE,...) {
  x <- new("dbframe", db = dbname, sql = table, extensions = extensions)
  
  if (!is.null(data)) {
    if (overwrite) clear(x, delete = FALSE)
    insert(x) <- as.data.frame(data)
  }
  x
}
@| dbframe @}

\section{Publication quality tables}

@o R/publictable.R @{
setGeneric("publictable", function(object,...)
           standardGeneric("publictable"))

setMethod("publictable", signature = c("dbframe"),
          function(object,...) {
            dots <- list(...)
            summarydata <- do.call("select", c(object = object, dots))
            do.call("dftable", c(object = summarydata, dots))})

setMethod("publictable", signature = c("data.frame"),
          function(object,...) dftable(object,...))

dftable <- function(dframe, align, digits, tabular.environment = "tabularx",
                    sanitize.text.function = function(x) x,...) {
  gsub("\\\\begin\\{tabularx\\}",
       "\\\\begin\\{tabularx\\}\\{\\\\textwidth\\}",
       print(xtable(dframe, align = align, digits = digits,...),
             file = "/dev/null", floating = FALSE,
             add.to.row = list(pos=list(-1, 0, nrow(summarydata)),
               command = c("\\toprule", "\\midrule", "\\bottomrule")),
             tabular.environment = tabular.environment,
             sanitize.text.function = sanitize.text.function))
}
@| publictable dftable @}

\appendix

\section{Namespace}

@o NAMESPACE @{
import(DBI, RSQLite, RSQLite.extfuns, xtable)
importFrom(utils, head, tail)
export(clear, db, dbframe, index, 'index<-', 'insert<-', 
       rows, select, sql, dfapply, pdfapply, publictable)
exportClass(dbframe)
exportMethods(dbConnect, "==", "!=")
S3method(head, dbframe)
S3method(tail, dbframe)
@}

\section{Licensing information for this software}

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or (at
your option) any later version.

This program is distributed in the hope that it will be useful, but
\textsc{without any warranty}; without even the implied warranty of
\textsc{merchantability} or \textsc{fitness for a particular purpose}.
See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see
\texttt{<http://www.gnu.org/licenses/>}.

\section{Index}

\subsection{Files generated}
@f

\subsection{Fragment names}
@m

\subsection{Variables}
@u

\end{document}
