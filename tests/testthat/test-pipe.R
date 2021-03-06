
test_that("exposition operator wraps `with()`", {
  out <- mtcars %>% identity() %$% (head(cyl) / mean(am))
  expect_identical(out, head(mtcars$cyl) / mean(mtcars$am))
})

test_that("compound operator works with fancy pipes", {
  data <- mtcars
  data %<>% identity %$% (head(cyl) / mean(am))
  data
  expect_identical(data, head(mtcars$cyl) / mean(mtcars$am))
})

test_that("eager pipe expressions are evaluated in the current environment", {
  rlang::local_bindings(`%>%` = pipe_eager_lexical)

  fn <- function(...) parent.frame()
  out <- NULL %>% identity() %>% fn()
  expect_identical(out, environment())

  fn <- function() {
    NULL %>% identity() %>% { return(TRUE) }
    FALSE
  }
  expect_true(fn())
})

test_that("`.` is restored", {
  1 %>% identity()
  expect_error(., "not found")

  . <- "foo"
  1 %>% identity()
  expect_identical(., "foo")
})

test_that("lazy pipe evaluates expressions lazily (#120)", {
   out <- stop("foo") %>% identity() %>% tryCatch(error = identity)
   expect_true(inherits(out, "simpleError"))

   ignore <- function(...) NA
   out <- stop("foo") %>% identity() %>% ignore()
   expect_identical(out, NA)
})

test_that("lazy pipe evaluates `.` in correct environments", {
  out <- NA %>% list(.) %>% list(.) %>% list(.)
  expect_identical(out, list(list(list(NA))))
})

test_that("nested pipe can't use multiple placeholders", {
  rlang::local_bindings(`%>%` = pipe_nested)
  expect_error(
    1 %>% list(., .),
    "multiple"
  )
})
