# %% GML - Gamma
# load data ----
insurance <- read.csv("insurance.csv")

# fitting models ----
# GLM with Gaussian distribution, log link function
model_gauss <- glm(claimcst0 ~ veh_value + veh_body + veh_age + gender + area + agecat,
                   data = insurance, offset = log(numclaims), family = gaussian(link="log"))

# GLM with Gamma distribution, log link function
model_gamma <- glm(claimcst0 ~ veh_value + veh_body + veh_age + gender + area + agecat,
                   data = insurance, offset = log(numclaims), family=Gamma(link="log"))

# coefficient estimates ----
# GLM Gaussion
summary(model_gauss)
plot(model_gauss)
# GLM Gamma
summary(model_gamma)
plot(model_gamma)
