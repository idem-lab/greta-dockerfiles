
dat <- dplyr::filter(iris, Species == 'setosa')

x <- dat$Petal.Length
y <- dat$Sepal.Length

sd_greta_array <- create_greta_arrays_sd()
observation_greta_arrays <- create_observation_model(sd_greta_array$sd, x, y)

combined_greta_arrays <- c(sd_greta_array, observation_greta_arrays)

m <- model(combined_greta_arrays$int,
           combined_greta_arrays$coef,
           combined_greta_arrays$sd)

draws <- mcmc(m, n_samples = 1000, chains = 4)
