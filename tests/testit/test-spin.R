library(testit)

spin_w_tempfile = function(..., format = "Rmd") {
  tmp = tempfile(fileext = ".R")
  writeLines(c(...), tmp)
  spinned = spin(tmp, knit = FALSE, format = format)
  result = readLines(spinned)
  file.remove(c(tmp, spinned))
  result
}

assert(
  "spin() detects lines for documentation",
  identical(spin_w_tempfile("#' test", "1 * 1", "#' test"),
            c("test", "", "```{r }", "1 * 1", "```", "", "test")),
  # a multiline string literal contains the pattern of doc or inline
  identical(spin_w_tempfile("code <- \"", "#' test\""),
            c("", "```{r }", "code <- \"", "#' test\"", "```", "")),
  identical(spin_w_tempfile("code <- \"", "{{ 1 + 1 }}", "\""),
            c("", "```{r }", "code <- \"", "{{ 1 + 1 }}", "\"", "```", "")),
  # a multiline symbol contains the pattern of doc or inline
  identical(spin_w_tempfile("`", "#' test", "`"),
            c("", "```{r }", "`", "#' test", "`", "```", "")),
  identical(spin_w_tempfile("`", "{{ 1 + 1 }}", "`"),
            c("", "```{r }", "`", "{{ 1 + 1 }}", "`", "```", ""))
)

assert(
  "spin() uses proper number of backticks",
  identical(spin_w_tempfile("{{ '`' }}"),
            c("``r  '`'  ``")),
  identical(spin_w_tempfile("{{`x`}}"),
            c("``r `x` ``")),
  identical(spin_w_tempfile("x <- '", "```", "'"),
            c("", "````{r }", "x <- '", "```", "'", "````", ""))
)
