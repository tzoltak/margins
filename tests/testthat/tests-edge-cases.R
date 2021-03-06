# test various edge cases
context("Edge case tests")

# set comparison tolerance
tol <- 0.0001

library("datasets")

test_that("margins() works with multicollinearity", {
    x <- lm(mpg ~ wt + I(wt*2), data = mtcars)
    suppressWarnings(m <- margins(x))
    expect_true(inherits(m, "data.frame"))
    expect_true(nrow(summary(m)) == 1L)
})

test_that("margins() works with only a term in I()", {
    x <- lm(mpg ~ I(wt*2), data = mtcars)
    suppressWarnings(m <- margins(x))
    expect_true(inherits(m, "data.frame"))
    expect_true(nrow(summary(m)) == 1L)
})

test_that("margins() works with missing factor levels", {
    mtcars2 <- mtcars
    mtcars2$cyl <- factor(mtcars2$cyl)
    mtcars2$gear <- factor(mtcars2$gear)
    x <- lm(mpg ~ cyl * gear, data = mtcars2)
    suppressWarnings(m <- margins(x))
    expect_true(inherits(m, "data.frame"))
    expect_true(nrow(summary(m)) == 4L)
    rm(mtcars2)
})

test_that("margins() works with `at` for a factor predictor", {
    mtcars2 <- mtcars
    mtcars2$cyl <- factor(mtcars2$cyl)
    x <- lm(mpg ~ cyl + gear, data = mtcars2)
    m <- margins(x, at = list(cyl = "6"))
    expect_true(inherits(m, "data.frame"))
    expect_equal(summary(m)$factor, c("cyl4", "cyl8", "gear"))
    expect_equivalent(summary(m)$AME, c(6.7470899, -4.2182834, 0.7430041), tolerance = tol)
    rm(mtcars2)
})

test_that("margins() errors correctly when there are no RHS variables", {
    x <- lm(mpg ~ 1, data = mtcars)
    expect_error(marginal_effects(x))
    expect_error(margins(x))
})

test_that("vce = 'bootstrap' works with one variable as variables argument", {
    x <- lm(mpg ~ wt + hp * cyl, data = mtcars)
    suppressWarnings(m <- margins(x, vce = "bootstrap", variables = "hp"))
    expect_true(inherits(m, "data.frame"))
    expect_true(nrow(summary(m)) == 1L)
})

test_that("vce = 'simulation' works with one variable as variables argument", {
    x <- lm(mpg ~ wt + hp * cyl, data = mtcars)
    suppressWarnings(m <- margins(x, vce = "simulation", variables = "hp"))
    expect_true(inherits(m, "data.frame"))
    expect_true(nrow(summary(m)) == 1L)
})
